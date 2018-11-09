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
                                            Constants.KDECONNECT_DEAMON,
                                            path,
                                            Constants.KDECONNECT_DEAMON_DEVICE,
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
            debug ("Subscribing pairing request");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
                                          "hasPairingRequestsChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }

        protected virtual uint subscribe_name_changed (ref DBusConnection conn, 
                                                       string path) {
            debug ("Subscribing name change");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
                                          "nameChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          string_signal_cb);
        }

        protected virtual uint subscribe_pairing_error (ref DBusConnection conn, 
                                                        string path) {
            debug ("Subscribing pairing error");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
                                          "pairingError",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          string_signal_cb);
        }

        protected virtual uint subscribe_plugins_changed (ref DBusConnection conn, 
                                                          string path) {
            debug ("Subscribing plugins change");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
                                          "pluginsChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          void_signal_cb);
        }

        protected virtual uint subscribe_reachable_status_changed (ref DBusConnection conn, 
                                                                   string path) {
            debug ("Subscribing status change");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
                                          "reachableChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }

        protected virtual uint subscribe_trusted_changed (ref DBusConnection conn, 
                                                          string path) {
            debug ("Subscribing trusted change");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEVICE,
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
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path,
                                                     Constants.KDECONNECT_DEAMON_DEVICE,
                                                     "hasPlugin",
                                                     new Variant ("(s)", plugin),
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                
                Variant i = return_variant.get_child_value (0);
                return_value = i.get_boolean ();
            } 
            catch (Error e) {
                debug (e.message);
            }
            debug (@"Device $path, Plugin $plugin, Exists %s", return_value.to_string ());
            return return_value;
        }

        protected virtual void accept_pairing (ref DBusConnection conn,
                                               string path) {            
            try {
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path,
                                Constants.KDECONNECT_DEAMON_DEVICE,
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
            debug (@"Device $path, Accept pairing request");
        }

        protected virtual void reject_pairing (ref DBusConnection conn,
                                               string path) {            
            try {
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path,
                                Constants.KDECONNECT_DEAMON_DEVICE,
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
            debug (@"Device $path, Reject pairing request");
        }

        protected virtual void unpair (ref DBusConnection conn,
                                       string path) {            
            try {
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path,
                                Constants.KDECONNECT_DEAMON_DEVICE,
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
            debug (@"Device $path, Unpair request");
        }

        protected virtual void request_pair (ref DBusConnection conn,
                                             string path) {            
            try {
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path,
                                Constants.KDECONNECT_DEAMON_DEVICE,
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
            debug (@"Device $path, request pairing");
        }

        protected virtual void property (ref DBusConnection conn,
                                         string path,
                                         string property_name,
                                         ref Value return_value) {
                                                         
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path,
                                                     Constants.KDECONNECT_DEBUS_PROP,
                                                     "Get",
                                                     new Variant ("(ss)",
                                                                  Constants.KDECONNECT_DEAMON_DEVICE,
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
                debug (e.message);
            }
            debug (@"Device $path, propertie request %s", return_value.strdup_contents ());
        }

        /*Callbacks */
        protected void void_signal_cb (DBusConnection con, 
                                       string sender,
                                       string object,
                                       string interface,
                                       string signal_name,
                                       Variant parameter) {

            debug (@"Device Signal: $signal_name, Value: None");
            
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
            debug (@"Device Signal: $signal_name, Value: $param");
            
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

            debug (@"Device Signal: $signal_name, Value: %s", param.to_string ());
            
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
