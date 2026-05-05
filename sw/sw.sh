#!/bin/bash

# get current profile and set alarm bell to true; if not true already
# start a timer with input till 0, with time.sleep
# on timer clear play alarm bell


DURATION=$1

if [[ ! -n $DURATION || ! $DURATION =~ ^[0-9]+$ ]];then
    cat << EOF
Usage: $(basename $0) [duration(seconds)]
EOF
exit 1
fi

function ringBell() {
    echo -ne "\r\033[0KTime's Up!\n"
    for j in {1..20};do
        echo -ne "\a"
        sleep 0.2
    done
}

PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default)
PROFILE_ID=${PROFILE_ID//\'}

CURRENT_BELL_STATE=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ audible-bell)
if ! $CURRENT_BELL_STATE;then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ audible-bell true
fi

for ((i=DURATION; i>=0; i--));do
    echo -ne "\rTime Left: ${i}"
    sleep 1
done
ringBell

if ! $CURRENT_BELL_STATE;then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/ audible-bell false 
fi
