KDE Connect Indicator
=====================
[![Translation Status](https://hosted.weblate.org/widgets/indicator-kde-connect/-/svg-badge.svg)](https://hosted.weblate.org/engage/indicator-kde-connect/?utm_source=widget)

This Indicator is written to make [KDE Connect](https://community.kde.org/KDEConnect) usable in desktops without KDE Plasma, such as Ubuntu Unity and Pantheon.  
It started as an [AppIndicator](https://unity.ubuntu.com/projects/appindicators/), but you can send files and URLs easily through KDE Connect with kdeconnect-send.

Features: 
-------
 1. Indicator in the panel which show your devices, with its name, status, and battery.
 2. Menu to request for pairing and unpairing.
 3. Menu to start SFTP and open a file browser.
 4. Menu to send files.
 5. A small program, `kdeconnect-send` to help sending file and choosing device.
 6. A .contractor file, so you can send file from any of elementary OS's applications.
 7. A Python extension for Nautilus, Nemo and Caja.
 8. Menu to ring and find your phone.
 9. From the device name menu you can get encryption information.
 10. From the device status menu item you can open KDE Connect settings.

Limitation
-------
Currently this is have some limitation:
 1. After changes on KDE Connect this will work only in KDE Connect 1.0.0 and up

Installation
-------
- Arch Linux  
 There is a package available in the [AUR](https://aur.archlinux.org/packages/indicator-kdeconnect-git)

- Ubuntu  
 Ubuntu 16.04 users can use this ppa:
```
sudo add-apt-repository ppa:varlesh-l/indicator-kdeconnect
sudo apt update
sudo apt install kdeconnect indicator-kdeconnect
```
 Ubuntu 16.10 users can use this ppa:
```
sudo add-apt-repository ppa:varlesh-l/indicator-kdeconnect
sudo sed -i 's/yakkety/xenial/g' /etc/apt/sources.list.d/varlesh-l-ubuntu-indicator-kdeconnect-yakkety.list
sudo apt update
sudo apt install indicator-kdeconnect kdeconnect
```

- Fedora  
 Fedora 25 user's can use this repo:
```
sudo dnf config-manager --add-repo http://download.opensuse.org/repositories/home:/Bajoja/Fedora_25/home:Bajoja.repo
sudo dnf install kdeconnectd indicator-kdeconnect -y
```

- From the Source  
 Check the INSTALL file

Usage Suggestions
-------
 To make life better you can try to apply this:

 1. Add KDE Connect Indicator to your startup applications, on your System Setting if is not.
 2. Nautilus, Nemo and Caja users have native extensions installed by default, make sure you have,
    python-nautilus, python-nemo or python-caja instelled to use it.
 3. If your files manager is not supported by extensions create a action entry with  `kdeconnect-send %f`as  command.
    Or you can use the script present on the scripts folder.

Please report issues and suggestion [here](https://github.com/Bajoja/indicator-kdeconnect/issues)

And help translate this project [here](https://hosted.weblate.org/projects/indicator-kde-connect/translations/)
