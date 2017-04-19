KDE Connect Indicator
=====================
[![Translation Status](https://hosted.weblate.org/widgets/indicator-kde-connect/-/svg-badge.svg)](https://hosted.weblate.org/engage/indicator-kde-connect/?utm_source=widget)
[![Build Status](https://travis-ci.org/Bajoja/indicator-kdeconnect.svg?branch=send-sms-dev)](https://travis-ci.org/Bajoja/indicator-kdeconnect)

This Indicator is written to make [KDE Connect](https://community.kde.org/KDEConnect) usable in desktops without KDE Plasma, such as Ubuntu Unity and Pantheon.  
It started as an [AppIndicator](https://unity.ubuntu.com/projects/appindicators/), but you can send files and URLs easily through KDE Connect with kdeconnect-send.

Features: 
-------
 1. Indicator in the panel which show your devices, with its name, status, and battery.
 2. Menu to request for pairing and unpairing.
 3. Menu to start SFTP and open a file browser.
 4. Menu to send files.
 5. Menu to send SMS.
 6. A small program, `kdeconnect-send` to help sending files and choosing device.
 7. A .contractor file, so you can send files from any of elementary OS's applications.
 8. A Python extension for Nautilus, Nemo and Caja.
 9. Menu to ring and find your phone.
 10. From the device name menu you can get encryption information.
 11. From the device status menu item you can open KDE Connect settings.
 12. Custom device icons for Ubuntu, Gnome and Elementary OS.

Limitation
-------
Currently this is have some limitation:
 1. After changes on KDE Connect this will work only in KDE Connect 1.0.0 and up

Installation
-------
- Arch Linux  
 There is a package available in the [AUR](https://aur.archlinux.org/packages/indicator-kdeconnect-git)

- Ubuntu and Linux Mint   
 Ubuntu 16.04, 16.10, 17.04 and Linux Mint 18.1 users can use this ppa:
```
sudo add-apt-repository ppa:webupd8team/indicator-kdeconnect
sudo apt update
sudo apt install kdeconnect indicator-kdeconnect
```

- Fedora  
 Fedora 25 user's can use this repo:
```
sudo dnf config-manager --add-repo http://download.opensuse.org/repositories/home:/Bajoja/Fedora_25/home:Bajoja.repo
sudo dnf install kdeconnectd indicator-kdeconnect -y
```

- OpenSuSe  
 OpenSuSe Leap 42.2 user's can use the first repo and Tumbleweed the secound repo:
```
http://download.opensuse.org/repositories/home:/Bajoja/openSUSE_Leap_42.2/

http://download.opensuse.org/repositories/home:/Bajoja/openSUSE_Tumbleweed/
```  

- From the Source  
 Check the INSTALL file

Usage Suggestions
-------
 To make life better you can try to apply this:

 1. Add KDE Connect Indicator to your startup applications, on your System Setting if is not.
 2. Nautilus, Nemo, Caja and Pantheon-files users have native extensions installed by default, make sure you have,
    `python-nautilus`, `python-nemo` or `python-caja` instelled to use it.
 3. If your files manager is not supported by extensions create a action entry with `kdeconnect-send %F` as command.
    Or you can use the script present on the scripts folder, adding it to your file manager script folder.

Please report issues and suggestion [here](https://github.com/Bajoja/indicator-kdeconnect/issues)

And help translate this project [here](https://hosted.weblate.org/projects/indicator-kde-connect/translations/)
