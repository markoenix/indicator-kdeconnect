KDE Connect Indicator
=====================
[![Translation Status](https://hosted.weblate.org/widgets/indicator-kde-connect/-/svg-badge.svg)](https://hosted.weblate.org/engage/indicator-kde-connect/?utm_source=widget)
[![Build Status](https://travis-ci.org/Bajoja/indicator-kdeconnect.svg?branch=master)](https://travis-ci.org/Bajoja/indicator-kdeconnect)

![indicator-kdeoconnect](https://raw.githubusercontent.com/Bajoja/indicator-kdeconnect/master/data/images/indicator-kdeconnect.jpg)

This Indicator is written to make [KDE Connect](https://community.kde.org/KDEConnect) usable in desktops without KDE Plasma, such as Ubuntu Unity and Pantheon.
It started as an [AppIndicator](https://unity.ubuntu.com/projects/appindicators/), but you can send files and URLs easily through KDE Connect with kdeconnect-send.

Features
-------
 1. Indicator in the panel which show your devices, with its name, status, and battery.
 2. Menu to request for pairing and unpairing.
 3. Menu to start SFTP and open a file browser.
 4. Menu to send files.
 5. Menu to send SMS.
 6. Menu to ring and find your phone.
 7. From the device name menu you can get encryption information.
 8. From the device status menu item you can open KDE Connect settings.
 9. A small program, `kdeconnect-send` to help sending files and choosing device.
 10. A .contractor file, so you can send files from any of elementary OS's applications.
 11. A .desktop file, so you can send files from file manager like Thunar.
 12. Python extensions for Nautilus, Nemo and Caja, you can send files directly from them.
 13. Custom device icons for Ubuntu, Gnome and Elementary OS.

Compatibility
-------
Any desktop that supports KStatusNotifierItem/AppIndicator icons should just work – Budgie, Cinnamon, LXDE, Pantheon, Unity, and many others.
The only major oddball is Gnome where you need an additional [Gnome Shell extension](https://extensions.gnome.org/extension/615/appindicator-support/) for proper support.

Another sulution is for Gnome Shell is consider to use [KDE Connect/MConnect integration for Gnome Shell](https://github.com/andyholmes/gnome-shell-extension-mconnect). It's a full integrated extension with the same features.

After changes on KDE Connect this will work only in KDE Connect 1.0.0 and up which can be problematic on Linux distributions released before August 2016.

Installation
-------
- Arch Linux
 There is a package available in the [AUR](https://aur.archlinux.org/packages/indicator-kdeconnect-git)

- Fedora and openSUSE
 Visit https://software.opensuse.org//download.html?project=home%3ABajoja&package=indicator-kdeconnect and select your operating system.

- Ubuntu and Linux Mint
 Ubuntu 16.04, 16.10, 17.04 and Linux Mint 18.1 users can use this PPA:
```
sudo add-apt-repository ppa:webupd8team/indicator-kdeconnect
sudo apt update
sudo apt install kdeconnect indicator-kdeconnect
```

- From the Source
 Check the INSTALL file

Usage Suggestions
-------
 To make life better you can try to apply this:

 1. Add KDE Connect Indicator to your startup applications, on your System Setting if is not.
 2. Nautilus, Nemo, Caja, Pantheon-files and Thunar users have native extensions installed by default, make sure you have,
    `python-nautilus`, `python-nemo` or `python-caja` instelled to use it.
 3. If your files manager is not supported by extensions create a action entry with `kdeconnect-send %F` as command.
    Or you can use the script present on the [scripts folder](https://github.com/Bajoja/indicator-kdeconnect/tree/master/scripts/kdeconnect-send), adding it to your file manager script folder.
 4. If you having troubles under Wayland install this [script](https://github.com/Bajoja/indicator-kdeconnect/tree/master/scripts/wayland). 


Please report issues and suggestion [here](https://github.com/Bajoja/indicator-kdeconnect/issues)

And help translate this project [here](https://hosted.weblate.org/projects/indicator-kde-connect/translations/)
