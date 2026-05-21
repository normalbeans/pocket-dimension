#!/bin/bash


PRIMARY=$'\e[32m'
SECONDARY=$'\e[31m'
NC=$'\e[0m'

declare -A quadrant

width=3
height=3


for (( i=0; i < height; i++ ));do
    for (( j=0; j<width; j++ ));do
        if (( RANDOM%2 ));then
            quadrant[$i,$j]="${PRIMARY}"$'\u2588\u2588'"${NC}"
        else
            quadrant[$i,$j]="${SECONDARY}"$'\u2588\u2588'"${NC}"
        fi
    done
done

for (( i=0; i < height; i++ ));do
    for (( j=0; j<width; j++ ));do
        printf "%s" "${quadrant[$i,$j]}"
    done
    printf "\n"
done