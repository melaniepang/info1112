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



dec_to_bin 20
