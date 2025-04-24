#!/bin/bash

status=""

if [ -z "$1" ] 
    then
    echo "No arguments provided"
    exit 2
fi

if [[ $1 == "--set" ]]; then
    if [[ $2 != "desktop" ]] && [[ $2 != "sddm" ]]; then
        echo Supply either "desktop" or "sddm"
        exit 2
    else
        status=$2
    fi
fi

if [[ $1 == "--update-using-sddm-session-check" ]]; then
    if `loginctl list-sessions | awk '{print $3}' | grep -q 'sddm'`; then
        status="sddm"
    else
        status="desktop"
    fi
fi

if [[ $3 == "--assume-no-shutdown" ]] && [ "$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager PreparingForShutdown | awk '{print $2}')" = "true" ]; then
    echo "Shutdown signal was available, value will not be changed!"
    exit 0
fi

if [[ $status == "" ]]; then
    echo "Wrong arguments provided"
    exit 2
fi

sed -i '/# START_USED_BY_SERVICE/,/# END_USED_BY_SERVICE/{ 
    /# START_USED_BY_SERVICE/!{ 
        /# END_USED_BY_SERVICE/!d 
    } 
    r /dev/stdin
}' /usr/share/plymouth/themes/PlymouthVista/PlymouthVista.script <<EOF
global.OsState = "$status";
EOF

echo "Updated status to $status"