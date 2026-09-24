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



if [[ $# -ne 1 ]]; then
    echo "Error: expected exactly one argument"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: file '$1' does not exist"
    exit 1
fi

if [[ "$1" != *.vsc  ]]; then
    echo "Error: file must have a .vsc extension"
    exit 1
fi

if [[ ! -s "$1" ]]; then
    echo "Warning: file is empty, no .bin produced"
    exit 1
fi

   mapfile -t lines < "$1"

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
    echo "Created $outfile"
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

echo "${dataArray[@]}"
