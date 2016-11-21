"""
 Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
"""

from gi.repository import Nautilus, GObject
from subprocess import call
import os.path
import urllib

class KdeConnectSendExtension(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        pass

    """Send a file with kdeconnect send"""
    def send_file(self, file):
        filename = urllib.unquote(file.get_uri()[7:])
        call(["kdeconnect-send", filename])

    """For every files you have selected, send one by one"""
    def menu_activate_cb(self, menu, files):
        for file in files:
            self.send_file(file)

    """Get files that user selected"""
    def get_file_items(self, window, files):

        """Ensure that user only select files"""
        for file in files:
            if file.get_uri_scheme() != 'file' or file.is_directory() and \
                    os.path.isfile(file):
                return

        """If user only select file(s) create menu item"""
        item = Nautilus.MenuItem(name='KdeConnectSendExtension::KDEConnect Send',
                                 label='KDEConnect Send',
                                 tip='send file(s) with kdeconnect-send',
                                 icon='kdeconnect')

        item.connect('activate', self.menu_activate_cb, files)

        return item,
