#!/bin/bash

dec_to_bin() {
    local num=$1
    local result=""
    for weight in 128 64 32 16 8 4 2 1; do
        if (( num >= weight )); then
            result+="1"
            (( num -= weight ))
        else
            result+="0"
        fi
    done
    echo "$result"
}



   if [[ $# -eq 0 ]]; then
    echo "usage: no argument is provided"
    exit 1
fi

if [[ $# -gt 1 ]]; then
    echo "usage: more than one arguments are provided"
    exit 1
fi

if [[ -e "$1" && ! -f "$1" ]]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi

if [[ "$1" != *.vsc ]]; then
    echo "usage: input does not have the extension .vsc"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi

if [[ ! -s "$1" ]]; then
    echo "usage: the file is empty – no .bin file is produced"
    exit 1
fi

   mapfile -t lines < "$1"

   lines=("${lines[@]%$'\r'}")


   if [[ "${lines[0]}" != "0" && "${lines[0]}" != "2" ]]; then
       echo "Error: line 1 must be 0 or 2"
       exit 1
   fi





outfile="${1%.vsc}.bin"

if [[ "${lines[0]}" == "0" ]]; then
    if [[ "${lines[1]}" != "QUIT,0,0" ]]; then
        echo "Error: expected QUIT,0,0 on line 2"
        exit 1
    fi
    printf '\x20\x00' > "$outfile"
       echo "It is a QUIT program"
       echo "The content of the .bin file is"
       echo "20"
       echo "00"
    exit 0
fi

dataArray=()

for i in 1 2; do
    val="${lines[$i]}"
    if [[ ! "$val" =~ ^[0-9]+$ ]] || (( 10#$val > 127 )); then
        echo "Error: line $((i+1)) must be a number from 0 to 127"
        exit 1
    fi
    dataArray+=("$(dec_to_bin $((10#$val)))")
done

count=0
found_quit=0

for (( i=3; i<${#lines[@]}; i++ )); do
    line="${lines[$i]}"

    if (( ${#line} > 11 )); then
        echo "Error: line $((i+1)) is too long"
        exit 1
    fi

    IFS=',' read -r ins reg mem <<< "$line"

    if [[ "$ins" == "LOAD" ]]; then opcode="000001"
    elif [[ "$ins" == "STORE" ]]; then opcode="000010"
    elif [[ "$ins" == "ADD" ]]; then opcode="000011"
    elif [[ "$ins" == "SUB" ]]; then opcode="000100"
    elif [[ "$ins" == "QUIT" ]]; then opcode="001000"
    elif [[ "$ins" == "PRINT" ]]; then opcode="001001"
    else
        echo "Error: unknown instruction '$ins' on line $((i+1))"
        exit 1
    fi

    if [[ ! "$reg" =~ ^[0-3]$ ]]; then
        echo "Error: register must be 0-3 on line $((i+1))"
        exit 1
    fi

    if [[ ! "$mem" =~ ^[0-9]+$ ]] || (( 10#$mem > 255 )); then
        echo "Error: memory address must be 0-255 on line $((i+1))"
        exit 1
    fi

    regbin=$(dec_to_bin "$reg")
    dataArray+=("$opcode${regbin:6:2}")
    dataArray+=("$(dec_to_bin $((10#$mem)))")

    (( count++ ))
    if (( count > 100 )); then
        echo "Error: more than 100 instructions"
        exit 1
    fi

    if [[ "$ins" == "QUIT" ]]; then
        if [[ "$line" != "QUIT,0,0" ]]; then
            echo "Error: QUIT must be exactly QUIT,0,0"
            exit 1
        fi
        found_quit=1
        break
    fi

done

if (( found_quit == 0 )); then
    echo "Error: program has no QUIT,0,0"
    exit 1
fi

   echo "It is an ADD/SUB program"
   echo "The content of the .bin file is"
   > "$outfile"
   for byte in "${dataArray[@]}"; do
       hex=$(printf '%02x' "$((2#$byte))")
       printf "\x$hex" >> "$outfile"
       echo "$hex"
   done
