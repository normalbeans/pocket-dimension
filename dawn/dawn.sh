#!/bin/bash

# dawm -p RGB -s RGB -a RGB -i <Image> --skip-image

# generate random grid
function generateGrid() {

    declare -A map
    declare -A quadrant

    # random quadrant of WIDTH x HEIGHT
    for (( i=0; i < HEIGHT; i++ ));do
        for (( j=0; j<WIDTH; j++ ));do
            if (( RANDOM%2 ));then
                quadrant[$i,$j]="${PRIMARY}"$'\u2588\u2588'"${NC}"
            else
                quadrant[$i,$j]="${SECONDARY}"$'\u2588\u2588'"${NC}"
            fi
        done
    done

    # map quadrant II to I, III and IV; axes as mirrors
    for (( i=0; i < HEIGHT; i++ ));do
        for (( j=0; j<WIDTH; j++ ));do
            map[$i,$j]=${quadrant[$i,$j]}
            map[$i,$((2*WIDTH-1-j))]=${quadrant[$i,$j]}
            map[$((2*HEIGHT-1-i)),$((2*WIDTH-1-j))]=${quadrant[$i,$j]}
            map[$((2*HEIGHT-1-i)),$j]=${quadrant[$i,$j]}
        done
    done

    # convert from matrix of blocks to array of rows
    for (( i=0; i < 2*HEIGHT; i++ )); do
        row_string=""
        for (( j=0; j<2*WIDTH; j++ )); do
            row_string+="${map[$i,$j]}"
        done
        SAMPLEIMAGE+=("$row_string")
    done

}

function generateImage() {
    NWIDTH=$((WIDTH*4))
    NHEIGHT=$((HEIGHT*2))
    readarray -t SAMPLEIMAGE < <(chafa --size "${NWIDTH}x${NHEIGHT}" --stretch "${IMAGEPATH}")
}


# vars
declare -a SAMPLEIMAGE

PRGB="170;130;255"
SRGB="215;255;130"
ARGB="255;255;255"

SCRIPTDIR="$(cd $(dirname $0) && pwd)"

MODE="GRID"
WIDTH=5
HEIGHT=4
IMAGEPATH="${SCRIPTDIR}/254.png"

octet="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
rgbpattern="^${octet};${octet};${octet}$"

while [[ $# -gt 0 ]];do
    case $1 in
        -p)
            if [[ $2 =~ $rgbpattern ]];then
                PRGB=$2
            fi
            shift 2
        ;;
        -s)
            if [[ $2 =~ $rgbpattern ]];then
                SRGB=$2
            fi
            shift 2
        ;;
        -a)
            if [[ $2 =~ $rgbpattern ]];then
                ARGB=$2
            fi
            shift 2
        ;;
        -i)
            IMAGEPATH=$2
            MODE="IMAGE"
            shift 2
        ;;
        --no-image)
            MODE="GRID"
            shift 1
        ;;
        *)
            printf "Unknown option: %s\n\nUsage: dawn -p \"R;G;B\" -s \"R;G;B\" -a \"R;G;B\" -i <image_path> [--no-image]"
        ;;
    esac
done


PRIMARY=$'\e[38;2;'"${PRGB}"$'m'
SECONDARY=$'\e[38;2;'"${SRGB}"$'m'
ACCENT=$'\e[38;2;'"${ARGB}"$'m'
NC=$'\e[0m'

if [[ ! -f "$IMAGEPATH" ]];then
    # defaulting to grid genreration
    MODE="GRID"
fi

# INFO section
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
SHELLINFO="${PRIMARY}Shell :${NC} ${SECONDARY}$(echo $(ps -p $(ps -p $$ -o tpgid=) -o comm=)) ${BASH_VERSION%%(*}${NC}"
OSINFO=$(awk -F"=" -v PRIMARY="${PRIMARY}" -v NC="${NC}" -v SECONDARY="${SECONDARY}" '/PRETTY_NAME/ { gsub(/"/, "", $2); printf "%sOS :%s %s%s%s", PRIMARY, NC, SECONDARY, $2, NC }' /etc/os-release)
MODELINFO="${PRIMARY}Model :${NC} ${SECONDARY}$(cat /sys/devices/virtual/dmi/id/product_name)${NC}"

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


if ! which chafa > /dev/null; then
        MODE="GRID"
fi

if [[ "${MODE}" == "GRID" ]];then
    generateGrid
else
    generateImage
fi

if (( ${#SAMPLEIMAGE[@]} > ${#INFOARRAY[@]} ));then
    max=${#SAMPLEIMAGE[@]}
else
    max=${#INFOARRAY[@]} 
fi


clean_box_row=$(echo -n ${SAMPLEIMAGE[0]} | sed 's/\x1b[[0-9;]*m//g')

# display here
printf $'\e[H\e[0J'"\n"
for (( i=0; i<max ; i++ )) ;do
    printf "  %-${#clean_box_row}s \t  %s\n" "${SAMPLEIMAGE[$i]}"  "${INFOARRAY[$i]}"
done
printf "\n"