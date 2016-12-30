"""
 Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.

 This contain parts of functions getted from https://github.com/forabi/nautilus-kdeconnect
"""

from gi.repository import Caja, GObject, Notify
from subprocess import call, check_output
import urllib, os.path, re

class KDEConnectExtension(GObject.GObject, Caja.MenuProvider):
    def __init__(self):
        pass

    """Get a list of reachable devices"""
    def get_reachable_devices(self):
        devices = check_output(["kdeconnect-cli", "-a"]).strip().split("\n")
        devices.pop()
        devices_a=[]
        for device in devices:
            device_name=re.search("(?<=-\s).+(?=:\s)", device).group(0)
            device_id=re.search("(?<=:\s)[a-z0-9]+(?=\s\()", device).group(0).strip()
            devices_a.append({ "name": device_name, "id": device_id })
        return devices_a

    """Send a files with kdeconnect"""
    def send_files(self, files, device_id, device_name):
        for file in files:
            filename = urllib.unquote(file.get_uri()[7:])
            call(["kdeconnect-cli", "-d", device_id, "--share", filename])

        Notify.init("KDEConnect-send")
        Notify.Notification.new("Check the device {device_name}".format(device_name=device_name),
                                "Sending {num_files} file(s)".format(num_files=len(files))
                                ).show()


    """Send selected files"""
    def menu_activate_cb(self, menu, files, device_id, device_name):
        self.send_files(files, device_id, device_name)

    """Get files that user selected"""
    def get_file_items(self, window, files):

        """Ensure there are reachable devices"""
        try:
            devices = self.get_reachable_devices()
        except Exception as e:
            raise Exception("Error while getting reachable devices")

        """Ensure that user only select files"""
        for file in files:
            if file.get_uri_scheme() != 'file' or file.is_directory() and os.path.isfile(file):
                return

        """If user only select file(s) create menu and sub menu"""
        menu = Caja.MenuItem(name='KdeConnectSendExtension::KDEConnect_Send',
                                 label='KDEConnect Send To',
                                 tip='send file(s) with kdeconnect',
                                 icon='kdeconnect')

        sub_menu = Caja.Menu()

        menu.set_submenu(sub_menu)

        for device in devices:
            item = Caja.MenuItem(name="KDEConnectExtension::Send_File_To",
                                     label=device["name"])
            item.connect('activate', self.menu_activate_cb, files, device["id"], device["name"])
            sub_menu.append_item(item)

        return menu,
