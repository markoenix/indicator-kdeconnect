#!/bin/sh

if [[ $UID != 0 ]]; then
    echo "Please start the script as root or sudo!"
    exit 1
fi

USER_HOME=$(eval echo ~${SUDO_USER})

if [ "$1" == "install" ]; then

echo "Coping indicator kdeconnect wayland script to bin"

sudo cp i_k_w.sh /usr/bin/

echo "Modifying autostart file ..."

echo "
[Desktop Entry]
Name=KDE Connect Indicator
Comment=An awesome system for Desktop-Phone continuity.
Exec=/usr/bin/./i_k_w.sh
Terminal=false
Type=Application
StartupNotify=true
Icon=kdeconnect
Categories=GNOME;GTK;System;" > $USER_HOME/.config/autostart/indicator-kdeconnect.desktop

echo "Modifying desktop application file ..."

echo "
Name=KDE Connect Indicator
Comment=An awesome system for Desktop-Phone continuity.
Exec=/usr/bin/./i_k_w.sh
Terminal=false
Type=Application
StartupNotify=true
Icon=kdeconnect" >  /usr/share/applications/indicator-kdeconnect.desktop


fi

if [ "$1" == "remove" ]; then
echo "Removing indicator kdeconnect wayland script to bin "

sudo rm /usr/bin/i_k_w.sh

echo "Modifying autostart file ..."

echo "
[Desktop Entry]
Name=KDE Connect Indicator
Comment=An awesome system for Desktop-Phone continuity.
Exec=indicator-kdeconnect
Terminal=false
Type=Application
StartupNotify=true
Icon=kdeconnect
Categories=GNOME;GTK;System;" > $USER_HOME/.config/autostart/indicator-kdeconnect.desktop

echo "Modifying desktop application file ..."

echo "
Name=KDE Connect Indicator
Comment=An awesome system for Desktop-Phone continuity.
Exec=indicator-kdeconnect
Terminal=false
Type=Application
StartupNotify=true
Icon=kdeconnect" >  /usr/share/applications/indicator-kdeconnect.desktop

fi
