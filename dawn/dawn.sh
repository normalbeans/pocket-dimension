#!/bin/bash


declare -a SAMPLEIMAGE
PRIMARY=$'\e[38;2;170;130;255m'
SECONDARY=$'\e[38;2;215;255;130m'
ACCENT=$'\e[38;2;255;255;255m'
NC=$'\e[0m'

function generateGrid() {

    declare -A map
    declare -A quadrant

    width=${1:-5}
    height=${2:-4}


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
            map[$i,$j]=${quadrant[$i,$j]}
            map[$i,$((2*width-1-j))]=${quadrant[$i,$j]}
            map[$((2*height-1-i)),$((2*width-1-j))]=${quadrant[$i,$j]}
            map[$((2*height-1-i)),$j]=${quadrant[$i,$j]}
        done
    done

    for (( i=0; i < 2*height; i++ )); do
        row_string=""
        for (( j=0; j<2*width; j++ )); do
            row_string+="${map[$i,$j]}"
        done
        SAMPLEIMAGE+=("$row_string")
    done

}

UPTIME=$(awk -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" '{
    sysuptime=int($1)
    days=int(sysuptime/86400)
    hours=int((sysuptime%86400)/3600)
    minutes=int((sysuptime%3600)/60)
    seconds=sysuptime%60
    printf "%sUptime :%s %s%d days %d hours %d minutes %d seconds%s\n", PRIMARY, NC, SECONDARY, days, hours, minutes, seconds, NC
}' /proc/uptime)
MEMINFO=$(awk -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" '
    /^MemTotal:/    {total = $2}
    /^MemAvailable:/ {avail = $2}
    END {
        used = (total - avail) / 1024 
        total = total / 1024 
        printf "%sMem :%s %s%dMi / %dMi%s\n", PRIMARY, NC, SECONDARY, used, total, NC
    }' /proc/meminfo)
USERHOSTINFO="${PRIMARY}${USER}${NC}${SECONDARY} @ ${NC}${PRIMARY}${HOSTNAME}${NC}"
SHELLINFO="${PRIMARY}Shell :${NC} ${SECONDARY}$(ps -p $$ -o comm=) ${BASH_VERSION%%(*}${NC}"
OSINFO=$(hostnamectl | awk -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" 'BEGIN{FS=": "}/Operating System/ {printf "%sOS :%s %s%s%s", PRIMARY, NC, SECONDARY, $2, NC}')
MODELINFO=$(hostnamectl | awk -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" 'BEGIN{FS=": "}/Hardware Model/ {printf "%sModel :%s %s%s%s", PRIMARY, NC, SECONDARY, $2, NC}')
STORAGEINFO=$(df -h / | awk -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" 'NR==2 {printf "%sStorage :%s %s%dGi / %dGi%s\n", PRIMARY, NC, SECONDARY, $3, $2, NC}')

uinfocleaned=$(echo -n ${USERHOSTINFO} | sed 's/\x1b[[0-9;]*m//g')

SEPARATOR=$(printf "%*s" "${#uinfocleaned}" | tr ' ' '-')

INFOARRAY=("${USERHOSTINFO}" \
    "${ACCENT}${SEPARATOR}${NC}" \
    "${SHELLINFO}" \
    "${OSINFO}" \
    "${MODELINFO}" \
    "${MEMINFO}" \
    "${STORAGEINFO}" \
    "${UPTIME}" )

if (( ${#SAMPLEIMAGE[@]} > ${#INFOARRAY[@]} ));then
    max=${#SAMPLEIMAGE[@]}
else
    max=${#INFOARRAY[@]} 
fi

generateGrid

clean_box_row=$(echo -n ${SAMPLEIMAGE[0]} | sed 's/\x1b[[0-9;]*m//g')

printf $'\e[H\e[0J'"\n"
for (( i=0; i<max ; i++ )) ;do
    printf "  %-${#clean_box_row}s \t  %s\n" "${SAMPLEIMAGE[$i]}"  "${INFOARRAY[$i]}"
done
printf "\n"