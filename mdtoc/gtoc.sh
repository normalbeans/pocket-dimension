#!/bin/bash

# Usage: gtoc file.md [-h] [-b|-n]
# Defaulted to skip heading and use bullets

FILE="${1}"
shift 1

SKIP_HEADING="true"
MODE="b"

while [[ $# -gt 0 ]];do
    case $1 in 
        -h)
            SKIP_HEADING="false"
            shift 1
        ;;
        -b)
            MODE="b"
            shift 1
        ;;
        -n)
            MODE="n"
            shift 1
        ;;
        *)
            echo "Unknown argument: $1"
        ;;
    esac
done


awk -v SKIPHEADING="${SKIP_HEADING}" -v MODE="${MODE}" '
BEGIN {
    toplevel=6
    n=0
    skipped=0
}

/^(#{1,6} ).*$/ {
    if (skipped==0 && SKIPHEADING=="true") {
        skipped=1
        next
    }
    level=$1
    heading=$0
    link=$0

    gsub(/#/, "", heading)
    gsub(/^[ \t]+/, "", heading)
    gsub(/[ \t]+$/, "", heading)

    gsub(/#/, "", link)
    gsub(/^[ \t]+/, "", link)
    gsub(/[ \t]+$/, "", link)
    gsub(/[[:punct:]]/, "", link)
    gsub(/[[:space:]]/, "-", link)
    link=tolower(link)

    lvl[n]=length(level)
    h[n]=heading
    l[n]=link
    n++

    toplevel=(length(level) < toplevel ? length(level) : toplevel)
}

END {
    for (i=0; i<n; i++) {
        printf "%-*s- [%s](#%s)\n", (toplevel-lvl[i])*4, "", h[i], l[i]
    }
}
' "${FILE}"

