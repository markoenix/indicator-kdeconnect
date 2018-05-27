/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Gee;

namespace IndicatorKDEConnect {  
    public class DeviceManager : Object, IDeviceManager {
        private DBusConnection conn;
        private DBusProxy device_proxy;
        private string path;
        private HashSet<uint> subs_identifier;

        public DeviceManager (string path) {
            this.path = path;

            try {
                conn = Bus.get_sync (BusType.SESSION);
                
                device_proxy = new DBusProxy.sync (conn,
                                                   DBusProxyFlags.NONE,
                                                   null,
                                                   "org.kde.kdeconnect",
                                                   path,
                                                   "org.kde.kdeconnect.device",
                                                   null);
                
                uint id;
                subs_identifier = new HashSet<uint> ();
                /* Signals For Device */
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "hasPairingRequestsChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            boolean_signal_cb);
                subs_identifier.add (id);

                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "nameChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            string_signal_cb);
                subs_identifier.add (id);

                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "pairingError",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            string_signal_cb);
                subs_identifier.add (id);
                                       
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "pluginsChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            void_signal_cb);
                subs_identifier.add (id);
                                       
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "reachableStatusChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            void_signal_cb);
                subs_identifier.add (id);
                                       
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device",
                                            "trustedChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            boolean_signal_cb);
                subs_identifier.add (id);

                /*Signals for Battery Module*/  
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.battery",
                                            "chargeChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            int32_signal_cb);
                subs_identifier.add (id);
                                       
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.battery",
                                            "stateChanged",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            boolean_signal_cb);
                subs_identifier.add (id);
                
                /*Signals for Notifications */
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.notifications",
                                            "notificationPosted",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            void_signal_cb);
                subs_identifier.add (id);

                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.notifications",
                                            "notificationRemoved",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            string_signal_cb);
                subs_identifier.add (id);

                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.notifications",
                                            "notificationPosted",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            string_signal_cb);
                subs_identifier.add (id);

                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.notifications",
                                            "allNotificationRemoved",
                                            path,
                                            null,
                                            DBusSignalFlags.NONE,
                                            string_signal_cb);
                subs_identifier.add (id);

                /*Signals for SFTP Module */
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.sftp",
                                            "mounted",
                                            path+"/sftp",
                                            null,
                                            DBusSignalFlags.NONE,
                                            void_signal_cb);
                subs_identifier.add (id);
                                       
                id = conn.signal_subscribe ("org.kde.kdeconnect",
                                            "org.kde.kdeconnect.device.sftp",
                                            "unmounted",
                                            path+"/sftp",
                                            null,
                                            DBusSignalFlags.NONE,
                                            void_signal_cb);
                subs_identifier.add (id);                                                 
            }
            catch (Error e) {
                debug (e.message);
            }            
        }   

        ~DeviceManager () {
            subs_identifier.@foreach ( (item) =>  {
                conn.signal_unsubscribe (item); 
            });
        }

        /*Device Methods */
        public bool has_plugin (string plugin) {
            var return_value = false;
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path,
                                                     "org.kde.kdeconnect.device",
                                                     "hasPlugin",
                                                     new Variant ("(s)", plugin),
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                
                Variant i = return_variant.get_child_value (0);

                if (i!=null)
                    return_value = i.get_boolean ();
            } 
            catch (Error e) {
                debug (e.message);
            }
            return return_value;
        }
    }
}