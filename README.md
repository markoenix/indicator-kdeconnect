KDE Connect Indicator
=====================

This Indicator is written to make [KDE Connect](https://community.kde.org/KDEConnect) usable in desktops without KDE.
It's started as an [AppIndicator](https://unity.ubuntu.com/projects/appindicators/), but you can send files and url easily through KDE Connect with kdeconnect-send.

Features: 
-------
 1. Indicator in the panel which show your devices, with its name, status, and battery.
 2. Menu to request for pairing and unpairing.
 3. Menu to start sftp and open file browser.
 4. Menu to send files.
 5. A small program, `kdeconnect-send` to help sending file and choosing device.
 6. A .contractor file, so you can send file from any of elementary OS's applications.
 7. Menu to ring and find your phone.
 8. From the device name menu you can get encryption information.
 9. From the device status menu item you can open kdeconnect settings.

Limitation
-------
Currently this is have some limitation:
 1. After changes on KDE Connect this will work only in KDE Connect 1.0.0 and up

Installation
-------
- Arch Linux  
 There is a package available in the AUR (https://aur.archlinux.org/packages/indicator-kdeconnect-git)

- Ubuntu  
 Ubuntu users can use this ppa:
```
sudo add-apt-repository ppa:varlesh-l/indicator-kdeconnect
sudo apt update
sudo apt install kdeconnect indicator-kdeconnect
```
- From the Source  
 Check the INSTALL file

Usage Suggestions
-------
 To make life better you can try to apply this:

 1. add KDE Connect Indicator to your startup applications, on your System Setting.
 2. for Nautilus or Thunar user, create a Nautilus-actions or Thunar-actions entry with  `kdeconnect-send %f`as  command.
 3. or you can use the file manager scripts present on the scripts folder.

Please report issues and suggestion here:
https://github.com/Bajoja/indicator-kdeconnect

And help translate this project here:
https://www.transifex.com/bajoja/indicator-kdeconnect
