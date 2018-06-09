/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Gee;

namespace IndicatorKDEConnect {  
    public class DeviceManager : Object, 
                                 ISettings,
                                 ISignals,
                                 IDevice,                                   
                                 IBattery,
                                 IFindMyPhone,
                                 IShare,
                                 ITelephony,
                                 ISftp {
        private DBusConnection conn;
        private DBusProxy proxy;
        private string path;
        private HashSet<uint> subs_identifier;
        private Settings settings;

        private string _id;
        private string _name;
        private string _icon;

        public DeviceManager (string path) {
            debug ("Creating manager for %s", path);
            this.path = path;

            try {
                conn = Bus.get_sync (BusType.SESSION);                

                proxy = device_proxy (ref conn, 
                                      path);

                subs_identifier = new HashSet<uint> ();
                
                uint id;
                            
                id = subscribe_has_pairing_requests_changed (ref conn,
                                                             path);
                subs_identifier.add (id);

                id = subscribe_name_changed (ref conn,
                                             path);
                subs_identifier.add (id);

                id = subscribe_pairing_error (ref conn,
                                              path);
                subs_identifier.add (id);
                                       
                id = subscribe_plugins_changed (ref conn,
                                                path);
                subs_identifier.add (id);
                                       
                id = subscribe_reachable_status_changed (ref conn, 
                                                path);
                subs_identifier.add (id);
                                       
                id = subscribe_trusted_changed (ref conn,
                                                path);
                subs_identifier.add (id);
                
                id = subscribe_battery_charge_changed (ref conn,
                                                       path);
                subs_identifier.add (id);
                                       
                id = subscribe_battery_state_changed (ref conn,
                                                      path);
                subs_identifier.add (id);

                this.settings = new Settings(Config.SETTINGS_NAME);

                subscribe_property_bool (ref settings,
                                         "only-paired-devices");
                subscribe_property_bool (ref settings,
                                         "info-item");
                subscribe_property_bool (ref settings,
                                         "browse-items");
                subscribe_property_bool (ref settings,
                                         "send-url");
                subscribe_property_bool (ref settings,
                                         "send-sms");
                subscribe_property_bool (ref settings,
                                         "find-my-device");

                /*Signals for Notifications */
                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.notifications",
                //                              "notificationPosted",
                //                              path,
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              void_signal_cb);
                //  subs_identifier.add (id);

                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.notifications",
                //                              "notificationRemoved",
                //                              path,
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              string_signal_cb);
                //  subs_identifier.add (id);

                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.notifications",
                //                              "notificationPosted",
                //                              path,
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              string_signal_cb);
                //  subs_identifier.add (id);

                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.notifications",
                //                              "allNotificationRemoved",
                //                              path,
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              string_signal_cb);
                //  subs_identifier.add (id);

                //  /*Signals for SFTP Module */
                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.sftp",
                //                              "mounted",
                //                              path+"/sftp",
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              void_signal_cb);
                //  subs_identifier.add (id);
                                       
                //  id = conn.signal_subscribe ("org.kde.kdeconnect",
                //                              "org.kde.kdeconnect.device.sftp",
                //                              "unmounted",
                //                              path+"/sftp",
                //                              null,
                //                              DBusSignalFlags.NONE,
                //                              void_signal_cb);
                //  subs_identifier.add (id);                                                 
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

        public string name {
            get {
                var val = Value (typeof (string)); 

                property (ref conn, 
                          path, 
                          "name",
                          ref val);

                _name = (string)val;
                return _name;
            }
        }

        public string id {
        	get {
        	     string device_path = "/modules/kdeconnect/devices/";
            	 _id = this.path.replace(device_path, "");

            	 return _id;
            }
        }

        public string icon {
	        get {
                var val = Value (typeof (string)); 
                property (ref conn, 
                          path, 
                          "statusIconName",
                          ref val);

                _icon = (string)val;
                return _icon;
            }
        }

        public bool is_reachable {
            get {
                var val = Value (typeof (bool)); 
                property (ref conn, 
                          path, 
                          "isReachable",
                          ref val);

                return (bool)val;                
            }
        }

        public bool has_pairing_requests {
            get {
                var val = Value (typeof (bool)); 
                property (ref conn, 
                          path, 
                          "hasPairingRequests",
                          ref val);

                return (bool)val;                
            }
        }

        public bool is_trusted {
            get {
                var val = Value (typeof (bool)); 
                property (ref conn, 
                          path, 
                          "isTrusted",
                          ref val);

                return (bool)val;                
            }
        }

        public int battery_charge {
            get {
                if (!_has_plugin ("kdeconnect_battery"))
                    return -1;
                else
                    return charge (ref conn,
                                   path);
            }
        }  
        
        public bool is_sftp_mounted {
            get {
                if (!_has_plugin ("kdeconnect_sftp"))
                    return false;
                else
                    return is_mounted (ref conn,
                                       path); 
            }
        }        

        public void _accept_pairing () {
            accept_pairing (ref conn, 
                            path);
        }

        public void _reject_pairing () {
            reject_pairing (ref conn, 
                            path);
        }

        public void _unpair () {
            unpair (ref conn,
                    path);
        }

        public void _request_pair () {
            request_pair (ref conn,
                          path);
        }

        public void _ring () {
            ring(ref conn,
                 path);
        }

        public bool _battery_charging () {
            if (!_has_plugin ("kdeconnect_battery"))
                return false;
            else 
                return is_charging(ref conn, path);
        }

        public void _share_url (string url) {
            share (ref conn,
                   path,
                   url);
        }

        public void _share_uris (SList<File> files) {
            files.@foreach ((item)=> {
                share (ref conn,
                       path,
                       item.get_uri ());
            });            
        }

        public SList<Pair<string,string>> _get_directories (bool cached_version = true) {
            var return_variant = get_directories (ref conn,
                                                  path);

            var directories = Utils.unvariant_data (return_variant);
            message ("Founded Directories %d", (int)directories.length ());
            try {
                if (directories.length () > 0) {
                    debug ("Saving folders data");
                    Json.Node root = Json.gvariant_serialize (return_variant);
                    Json.Generator generator = new Json.Generator ();
                    generator.set_root (root);
                    int saved = Utils.serialize_folders (id, generator.to_data (null));                    
                    debug ("Data folder saved : %d", saved);
                }                
                else {
                    if (cached_version) {
                        debug ("Reading data from folders");
                        string data = Utils.unserialize_folders (id);
                        if (data != null) {
                            Json.Parser parser = new Json.Parser ();
                            parser.load_from_data (data);
                            Json.Node node = parser.get_root ();
                            Variant variant = Json.gvariant_deserialize (node, null);
                            directories = Utils.unvariant_data (variant);
                        }
                    }
                }           
            }
            catch (Error e) {
                debug (e.message);
            }
                                                
            return directories;
        }

        public void mount_sftp () {
            if (!_has_plugin ("kdeconnect_sftp"))
                return;

            mount(ref conn,
                path);        
        }

        public void browse (string path_to_open="") {
            if (!_has_plugin ("kdeconnect_sftp"))
                return;

            string _mount_point = mount_point (ref conn,
                                               path);

            message("Open the path %s", path_to_open.length == 0 ? 
                                        _mount_point : 
                                        path_to_open);
            if (is_sftp_mounted) {
                Utils.open_file (path_to_open.length == 0 ? 
                                 _mount_point : 
                                 path_to_open);
            }
            else {
                mount_sftp ();
                Timeout.add (1000, ()=> { // idle for a few second to let sftp kickin
                    Utils.open_file (path_to_open.length == 0 ? 
                                     _mount_point : 
                                     path_to_open);
                    return false;
                });
            }
        }

        public bool _has_plugin (string plugin) {
            return has_plugin (ref conn,
                               path,
                               plugin);
        }

        public bool _get_property_bool(string property) {
            return get_property_bool (ref settings,
                                      property);
        }
        
        
    }
}