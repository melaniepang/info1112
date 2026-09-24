#!/bin/bash

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
