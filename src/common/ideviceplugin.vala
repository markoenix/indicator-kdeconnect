/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IDevice : Object { 
        /* Proxy */ 
        protected virtual DBusProxy device_proxy (ref DBusConnection conn,
                                                  string path) {
            DBusProxy proxy = null;
            try {
                proxy = new DBusProxy.sync (conn,
                                            DBusProxyFlags.NONE,
                                            null,
                                            "org.kde.kdeconnect",
                                            path,
                                            "org.kde.kdeconnect.device",
                                            null);
            }
            catch (Error e) {
                debug (e.message);
            }
            return proxy;
        } 
        
        /*Signals Subscribes */
        protected virtual uint subscribe_has_pairing_requests_changed (ref DBusConnection conn, 
                                                                       string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "hasPairingRequestsChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }

        protected virtual uint subscribe_name_changed (ref DBusConnection conn, 
                                                       string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "nameChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          string_signal_cb);
        }

        protected virtual uint subscribe_pairing_error (ref DBusConnection conn, 
                                                        string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "pairingError",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          string_signal_cb);
        }

        protected virtual uint subscribe_plugins_changed (ref DBusConnection conn, 
                                                          string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "pluginsChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          void_signal_cb);
        }

        protected virtual uint subscribe_reachable_status_changed (ref DBusConnection conn, 
                                                                   string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "reachableChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }

        protected virtual uint subscribe_trusted_changed (ref DBusConnection conn, 
                                                          string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device",
                                          "trustedChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }
        
        /*Methods */
        protected virtual bool has_plugin (ref DBusConnection conn,
                                           string path,
                                           string plugin) {
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

        protected virtual void accept_pairing (ref DBusConnection conn,
                                               string path) {            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device",
                                "acceptPairing",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);
            } 
            catch (Error e) {
                debug (e.message);
            }            
        }

        protected virtual void reject_pairing (ref DBusConnection conn,
                                               string path) {            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device",
                                "rejectPairing",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);
            } 
            catch (Error e) {
                debug (e.message);
            }            
        }

        protected virtual void unpair (ref DBusConnection conn,
                                       string path) {            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device",
                                "unpair",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);
            } 
            catch (Error e) {
                debug (e.message);
            }            
        }

        protected virtual void request_pair (ref DBusConnection conn,
                                             string path) {            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device",
                                "requestPair",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);
            } 
            catch (Error e) {
                debug (e.message);
            }            
        }

        protected virtual void property (ref DBusConnection conn,
                                        string path, 
                                        string property_name,
                                        ref Value return_value) {            
                                                         
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path,
                                                     "org.freedesktop.DBus.Properties",
                                                     "Get",
                                                     new Variant ("(ss)",
                                                                  "org.kde.kdeconnect.device",
                                                                  property_name),
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                Variant v = return_variant.get_child_value (0).get_variant ();                    
                                                          
                switch (return_value.type()) {
                    case Type.STRING:
                        return_value.set_string ("%s".printf(Uri.unescape_string (v.get_string (), 
                                                                                  null)));
                    break;

                    case Type.BOOLEAN:
                        return_value.set_boolean (v.get_boolean ());
                    break;
                }                                                                         
            } 
            catch (Error e) {
                message (e.message);
            }            
        }

        /*Callbacks */
        protected void void_signal_cb (DBusConnection con, 
                                    string sender, 
                                    string object,
                                    string interface, 
                                    string signal_name, 
                                    Variant parameter) {        

            debug ("Device Signal: %s, Value: None", signal_name);
            
            switch (signal_name) {
                case "pluginsChanged":
                    plugins_changed ();
                break;
            }
        }        

        protected void string_signal_cb (DBusConnection con, 
                                      string sender, 
                                      string object,
                                      string interface, 
                                      string signal_name, 
                                      Variant parameter) {
            string param = parameter.get_child_value (0).get_string ();
            debug ("Device Signal: %s, Value: %s", signal_name, param);
            
            switch (signal_name) {
                case "nameChanged":
                    name_changed (param);
                break;

                case "pairingError":
                    pairing_error_changed (param);
                break;
            }
        }

        protected void boolean_signal_cb (DBusConnection con, 
                                       string sender, 
                                       string object,
                                       string interface, 
                                       string signal_name, 
                                       Variant parameter) {        
            bool param = parameter.get_child_value (0).get_boolean ();
            
            debug ("Device Signal: %s, Value: %s", signal_name, param.to_string ());
            
            switch (signal_name) {                                        
                case "trustedChanged" :
                    trusted_status_changed (param);
                break;

                case "reachableChanged" :
                    reachable_status_changed (param);
                break;
                
                case "hasPairingRequestsChanged" :
                    has_pairing_requests_changed (param);
                break;
            }                    
        }

        /*Signals CallBack */
        public signal void name_changed (string name);        
        public signal void trusted_status_changed (bool trusted);
        public signal void reachable_status_changed (bool reachable);
        public signal void pairing_error_changed (string error);    
        public signal void has_pairing_requests_changed (bool has_pairing);    
        public signal void plugins_changed ();              
    }
}