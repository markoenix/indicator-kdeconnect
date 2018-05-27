/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {  
    public class Device : Object {
        public string path {get; private set;}
        private DeviceManager deviceManager;

        public Device (string path) {
            this.path = path;
            deviceManager = new DeviceManager(path);
        }   

        ~Device () {

        }
    }
}