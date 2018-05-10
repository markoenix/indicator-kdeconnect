/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace KDEConnectIndicator {
    public class Device {
        private DBusConnection conn;
        private DBusProxy device_proxy;
        private string path;
        private SList<uint> subs_identifier;
        private GLib.Settings settings;
        
        private string _name;
        public string name {
            get {
                try {
                     var return_variant = conn.call_sync (
                             "org.kde.kdeconnect",
                             path,
                             "org.freedesktop.DBus.Properties",
                             "Get",
                             new Variant ("(ss)","org.kde.kdeconnect.device","name"),
                             null,
                             DBusCallFlags.NONE,
                             -1,
                             null
                             );
                     Variant s = return_variant.get_child_value (0);
                     Variant v = s.get_variant ();
                     string d = v.get_string ();
                     _name = "%s".printf(Uri.unescape_string (d, null));
                } catch (Error e) {
                    message (e.message);
                }
                return _name;
            }
        }
        
        private string _id;
        public string id {
        	get {
        	     string device_path = "/modules/kdeconnect/devices/";
            	 _id = this.path.replace(device_path, "");

            	 return _id;
            }
        }

        private string _icon;
        public string icon {
	        get {
		        try {
		             var return_variant = conn.call_sync (
			        "org.kde.kdeconnect",
			        path,
			        "org.freedesktop.DBus.Properties",
			        "Get",
			        new Variant("(ss)","org.kde.kdeconnect.device","statusIconName"),
			        null,
			        DBusCallFlags.NONE,
			        -1,
			        null
	                );

                    Variant s = return_variant.get_child_value (0);
                    Variant v = s.get_variant ();
                    string d = v.get_string ();
                    string icon = "%s".printf(Uri.unescape_string (d, null));

                    _icon = icon;

	    	    } catch (Error e) {
		            message (e.message);
                }
            
		        return _icon;
	        }
        }
        
        public int battery {
            get {
                if (!has_plugin ("kdeconnect_battery"))
                    return -1;

                try {
                      var return_variant = conn.call_sync (
                              "org.kde.kdeconnect",
                              path,
                              "org.kde.kdeconnect.device.battery",
                              "charge",
                              null,
                              null,
                              DBusCallFlags.NONE,
                              -1,
                              null
                              );
                      Variant i = return_variant.get_child_value (0);
                     
                      if (i!=null)
                          return i.get_int32 ();
                } catch (Error e) {
                    message (e.message);
                }
                
                return -1;
            }
        }

        public bool to_hidde{
        	get {
        	     return this.settings.get_boolean ("visibilitiy");
        	}
        }

        public bool to_list_dir{
        	get {
        	     return this.settings.get_boolean ("list-device-dir");
        	}
        }

        public Device (string path) {
            message ("device : %s",path);
            this.path = path;

            try {
                 conn = Bus.get_sync (BusType.SESSION);
            } catch (Error e) {
                 error (e.message);
            }

            try {
                 device_proxy = new DBusProxy.sync (
                         conn,
                         DBusProxyFlags.NONE,
                         null,
                         "org.kde.kdeconnect",
                         path,
                         "org.kde.kdeconnect.device",
                         null
                         );
            } catch (Error e) {
                message (e.message);
            }

            uint id;
            subs_identifier = new SList<uint> ();
            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device",
                    "pairingError",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    string_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device",
                    "pluginsChanged",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    void_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device",
                    "reachableStatusChanged",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    void_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device",
                    "trustedChanged",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    boolean_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device.battery",
                    "chargeChanged",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    int32_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device.battery",
                    "stateChanged",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    boolean_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device.sftp",
                    "mounted",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    void_signal_cb
                    );
            subs_identifier.append (id);

            id = conn.signal_subscribe (
                    "org.kde.kdeconnect",
                    "org.kde.kdeconnect.device.sftp",
                    "unmounted",
                    path,
                    null,
                    DBusSignalFlags.NONE,
                    void_signal_cb
                    );
            subs_identifier.append (id);

            this.settings = new Settings("com.bajoja.indicator-kdeconnect");
        }

        ~Device () {
            if (is_mounted ())
                unmount ();

            foreach (uint i in subs_identifier) {
                conn.signal_unsubscribe (i);
            }
        }

        public void send_file (string url) {
            try {
                if (!has_plugin ("kdeconnect_share"))
                    return;
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path+"/share",
                        "org.kde.kdeconnect.device.share",
                        "shareUrl",
                        new Variant ("(s)",url),
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            } catch (Error e) {
                message (e.message);
            }
        }
        
        public bool is_trusted {
	        get {
		        try {
		            var return_variant = conn.call_sync (
		     		        "org.kde.kdeconnect",
				            path,
				            "org.kde.kdeconnect.device",
				            "isTrusted",
				            null,
				            null,
				            DBusCallFlags.NONE,
				            -1,
				            null
				            );

		            Variant i = return_variant.get_child_value (0);
                    
                    if (i!=null)
			            return i.get_boolean ();
		        } catch (Error e) {
		            message (e.message);
		        }
                
                return false; // default to false if something went wrong
	        }
        }

        public bool is_reachable {
            get {
		        try {
		            Variant return_variant = conn.call_sync (
				    "org.kde.kdeconnect",
				    path,
				    "org.freedesktop.DBus.Properties",
				    "Get",
				    new Variant("(ss)","org.kde.kdeconnect.device","isReachable"),
				    null,
				    DBusCallFlags.NONE,
				    -1,
				    null
				    );

		            Variant rtn_var = return_variant.get_child_value (0);
		            Variant v = rtn_var.get_variant ();

                    if(v!=null)
			            if(to_hidde)
			   	            return is_trusted? v.get_boolean () : false;
			            else
			   	            return v.get_boolean ();
		            else
		                return false;
		        } catch (Error e) {
                    message (e.message);
		        }
                
                return false; // default to false if something went wrong
            }
        }
        
        public bool is_charging () {
            if (!has_plugin ("kdeconnect_battery"))
                return false;

            try {
                var return_variant = conn.call_sync (
                        "org.kde.kdeconnect",
                        path,
                        "org.kde.kdeconnect.device.battery",
                        "isCharging",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
                Variant i = return_variant.get_child_value (0);
                
                if (i!=null)
                    return i.get_boolean ();
            } catch (Error e) {
                message (e.message);
            }
            return false;
        }
        
        public bool has_plugin (string plugin) {
            try {
                var return_variant = conn.call_sync (
                        "org.kde.kdeconnect",
                        path,
                        "org.kde.kdeconnect.device",
                        "hasPlugin",
                        new Variant ("(s)", plugin),
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
                
                Variant i = return_variant.get_child_value (0);
                if (i!=null)
                    return i.get_boolean ();
            } catch (Error e) {
                message (e.message);
            }

            return false;
        }
        
        public void request_pair () {
            try {
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path,
                        "org.kde.kdeconnect.device",
                        "requestPair",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            } catch (Error e) {
                message (e.message);
            }
        }
        
        public void unpair () {
            try {
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path,
                        "org.kde.kdeconnect.device",
                        "unpair",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            } catch (Error e) {
                message (e.message);
            }
        }
        
        public void browse (string open_path="") {
            if (!has_plugin ("kdeconnect_sftp"))
                return;

            if (is_mounted ())
                open_file (open_path.length == 0 ? mount_point : open_path);
            else {
                mount();
                Timeout.add (1500, ()=> { // idle for a few second to let sftp kickin
                        open_file (open_path.length == 0 ? mount_point : open_path);
                        return false;
                });
            }
        }
        
        public bool is_mounted () {
            try {
                var return_variant = conn.call_sync (
                        "org.kde.kdeconnect",
                        path+"/sftp",
                        "org.kde.kdeconnect.device.sftp",
                        "isMounted",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
                Variant i = return_variant.get_child_value (0);
                if (i!=null)
                    return i.get_boolean ();
            } catch (Error e) {
                message (e.message);
            }
            return false;
        }
        
        private string _mount_point;
        private string mount_point {
            get {
                try {
                    var return_variant = conn.call_sync (
                            "org.kde.kdeconnect",
                            path+"/sftp",
                            "org.kde.kdeconnect.device.sftp",
                            "mountPoint",
                            null,
                            null,
                            DBusCallFlags.NONE,
                             -1,
                            null
                            );
                    Variant i = return_variant.get_child_value (0);
                    _mount_point= i.dup_string ();
                    return _mount_point;
                } catch (Error e) {
                    message (e.message);
                }
            
                return "";
            }
        }

        public void mount (bool mount_and_wait=false) {
            try {
                if (!has_plugin ("kdeconnect_sftp"))
                    return;

		    if (mount_and_wait)
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path+"/sftp",
                        "org.kde.kdeconnect.device.sftp",
                        "mountAndWait",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            else
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path+"/sftp",
                        "org.kde.kdeconnect.device.sftp",
                        "mount",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            } catch (Error e) {
                message (e.message);
            }
        }
        
        public void unmount () {
            try {
                if (!has_plugin ("kdeconnect_sftp"))
                    return;
                
                conn.call_sync (
                        "org.kde.kdeconnect",
                        path+"/sftp",
                        "org.kde.kdeconnect.device.sftp",
                        "unmount",
                        null,
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
                        );
            } catch (Error e) {
                message (e.message);
            }
        }
        
        public HashTable<string, string> get_directories () {
            try {
                var return_variant = conn.call_sync (
                            "org.kde.kdeconnect",
                            path+"/sftp",
                            "org.kde.kdeconnect.device.sftp",
                            "getDirectories",
                            null,
                            null,
                            DBusCallFlags.NONE,
                            -1,
                            null
                            );

		        HashTable<string, string> directories = new HashTable<string, string> (str_hash, str_equal);

                Variant variant = return_variant.get_child_value (0);
                VariantIter iter = variant.iterator ();

                Variant? val = null;
                string? key = null;

	            while (iter.next ("{sv}", &key, &val))
    			    directories.insert (key, val.dup_string ());		    
            
                return directories;

            } catch (Error e) {
            	message (e.message);
            }
        
            return new HashTable<string, string> (str_hash, str_equal);
        }

        private bool open_file (string path) {
            var file = File.new_for_path (path);
            try {
                var handler = file.query_default_handler (null);
                var list = new List<File> ();
                list.append (file);
                return handler.launch (list, null);
            } catch (Error e) {
                message (e.message);
            }
            return false;
        }

        public void find_my_phone (){
	        try{
 		        conn.call_sync (
 	                "org.kde.kdeconnect",
                    path+"/findmyphone",
                    "org.kde.kdeconnect.device.findmyphone",
                    "ring",
                    null,
                    null,
                    DBusCallFlags.NONE,
                    -1,
                    null
                    );
	        } catch (Error e) {
		        message (e.message);
	        }
        }

	    private string _encryption_info;
	    public string encryption_info {
	        get {
                try {
                    var return_variant = conn.call_sync (
                                "org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device",
                                "encryptionInfo",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null
                                );

                    Variant i = return_variant.get_child_value (0);
                
                    return _encryption_info = i.dup_string ();
                } catch (Error e) {
                    message (e.message);
                }
                
                return _encryption_info = _("Encryption information not found");
            }
	    }

	    public void send_sms (string phone_number, string message_body){
	        try {
		        if (!has_plugin ("kdeconnect_telephony"))
		            return;
                
                conn.call_sync (
		    	        "org.kde.kdeconnect",
                        path+"/telephony",
                        "org.kde.kdeconnect.device.telephony",
                        "sendSms",
                        new Variant ("(ss)",phone_number, message_body),
                        null,
                        DBusCallFlags.NONE,
                        -1,
                        null
		                );
	        } catch (Error e) {
	            message (e.message);
	        }
	    }

        public void int32_signal_cb (DBusConnection con, string sender, string object,
                                     string interface, string signal_name, Variant parameter) {            
            int param = (int)parameter.get_child_value (0).get_int32 ();
            
            switch (signal_name) {
                case "chargeChanged" :
                    charge_changed ((int)param);
                    break;
            }
        }

        public void void_signal_cb (DBusConnection con, string sender, string object,
                                    string interface, string signal_name, Variant parameter) {
            
            switch (signal_name) {
                case "pluginsChanged" :
                    plugins_changed ();
                break;
            
                case "reachableStatusChanged" :
		            reachable_status_changed ();
                break;
                
                case "mounted" :
                    mounted ();
                break;
                
                case "unmounted" :
                    unmounted ();
                break;
            }
        }

        public void boolean_signal_cb (DBusConnection con, string sender, string object,
                                       string interface, string signal_name, Variant parameter) {
            bool param = parameter.get_child_value (0).get_boolean ();
            
            switch (signal_name) {
                case "stateChanged" :
                    state_changed (param);
                break;
            
                case "trustedChanged" :
                    trusted_changed (param);
                break;
            }
        }

        public void string_signal_cb (DBusConnection con, string sender, string object,
                                      string interface, string signal_name, Variant parameter) {
            string param = parameter.get_child_value (0).get_string ();
            
            switch (signal_name) {
                case "pairingError" :
                    pairing_error (param);
                break;
            }
        }
		
        public signal void charge_changed (int charge);
        public signal void pairing_error (string error);
        public signal void trusted_changed (bool trusted);
        public signal void plugins_changed ();
        public signal void reachable_status_changed ();
        public signal void mounted ();
        public signal void unmounted ();
        public signal void state_changed (bool state);
    }
}