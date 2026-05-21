#!/bin/bash


UPTIME=$(awk '{
    sysuptime=int($1)
    days=int(sysuptime/86400)
    hours=int((sysuptime%86400)/3600)
    minutes=int((sysuptime%3600)/60)
    seconds=sysuptime%60
    printf "Uptime : %d days %d hours %d minutes %d seconds\n", days, hours, minutes, seconds
}' /proc/uptime)
MEMINFO=$(awk '
    /^MemTotal:/    {total = $2}
    /^MemAvailable:/ {avail = $2}
    END {
        used = (total - avail) / 1024 
        total = total / 1024 
        printf "Mem : %dMi / %dMi\n", used, total
    }' /proc/meminfo)
USERHOSTINFO="${USER}@${HOSTNAME}"
SHELLINFO="Shell : $(ps -p $$ -o comm=) ${BASH_VERSION%%(*}"
OSINFO=$(hostnamectl | awk 'BEGIN{FS=": "}/Operating System/ {printf "OS : %s", $2}')
MODELINFO=$(hostnamectl | awk 'BEGIN{FS=": "}/Hardware Model/ {printf "Model : %s", $2}')
STORAGEINFO=$(df -h / | awk 'NR==2 {printf "Storage : %dGi / %dGi\n", $3, $2}')


SAMPLEIMAGE=($'\u2580\u2580\u2584\u2584\u2580\u2580\u2580\u2580\u2584\u2584\u2580\u2580' \
    $'\u2580\u2580\u2584\u2584\u2580\u2580\u2580\u2580\u2584\u2584\u2580\u2580' \
    $'\u2580\u2580\u2584\u2584\u2580\u2580\u2580\u2580\u2584\u2584\u2580\u2580' \
    $'\u2580\u2580\u2584\u2584\u2580\u2580\u2580\u2580\u2584\u2584\u2580\u2580' )

INFOARRAY=("${USERHOSTINFO}" \
    "--------------------" \
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

width=15

printf "$'\e[H\e[0J'\n"

for (( i=0; i<max ; i++ )) ;do
    printf " %-${width}s \t %s\n" "${SAMPLEIMAGE[$i]}"  "${INFOARRAY[$i]}"
done

printf "\n"