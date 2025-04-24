#!/bin/bash

# IMPORTANT: This install script has only been tested on Fedora Linux.
# Installation procedure may vary from distribution-to-distribution.


if [[ "$EUID" != 0 ]]
then
    echo "You need to run this script as root."
    exit 2
fi

echo "Do you want fade in effects in shutdown?"
echo "1 - Automatic (Fade on desktop, don't fade on SDDM)"
echo "2 - Always"
echo "3 - Never"
read -p "Your choice (1/2/3): " INPUT

if [[ $INPUT != 1 ]] && [[ $INPUT != 2 ]] then
    $INPUT = 0;
fi

sed -i '/# START_USED_BY_INSTALL_SCRIPT/,/# END_USED_BY_INSTALL_SCRIPT/{ 
    /# START_USED_BY_INSTALL_SCRIPT/!{ 
        /# END_USED_BY_INSTALL_SCRIPT/!d 
    } 
    r /dev/stdin
}' PlymouthVista.script <<EOF
global.Pref = $INPUT;
EOF

cp ./lucon_disable_anti_aliasing.conf /etc/fonts/conf.d/10-lucon_disable_anti_aliasing.conf
echo "Installed Font configuration"

if [ -d "/usr/share/plymouth/themes/PlymouthVista" ]; then
    rm -rf /usr/share/plymouth/themes/PlymouthVista
fi

cp -r $(pwd) /usr/share/plymouth/themes/PlymouthVista
echo "Theme is placed to its location."

if [[ $INPUT = 1 ]] then
    echo "Creating automatic service"
    chmod -R 777 /usr/share/plymouth/themes/PlymouthVista/

    cp $(pwd)/systemd/system/* /etc/systemd/system
    for f in $(pwd)/systemd/system/*.service; do
        systemctl enable $(basename $f)
    done

    cp $(pwd)/systemd/user/* /etc/systemd/user
        for f in $(pwd)/systemd/user/*.service; do
        systemctl --user -M $SUDO_USER@ enable update-plymouth-vista-state-logon.service
    done

fi


plymouth-set-default-theme -R PlymouthVista

