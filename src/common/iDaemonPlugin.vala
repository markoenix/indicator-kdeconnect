/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IDaemon : Object {    
        /*Contracts */        
        protected abstract void add_device (string path);
        protected abstract void remove_device (string path);
        protected abstract void distribute_visibility_changes (string path, bool visible);

        /*Methods */
        protected virtual DBusProxy daemon_proxy (ref DBusConnection conn) {
            DBusProxy proxy = null;
            try {
                proxy = new DBusProxy.sync (conn,
                                            DBusProxyFlags.NONE,
                                            null,
                                            Constants.KDECONNECT_DEAMON,
                                            Constants.MODULE_PATH,
                                            Constants.KDECONNECT_DEAMON_DEAMON,
                                            null);
            }
            catch (Error e) {
                debug (e.message);
            }
            return proxy;
        }

        protected virtual string[] devices (ref DBusConnection conn,
                                            bool only_reachable = false,
                                            bool only_paired = false) {
            string[] devices = {}; 
            try {
                debug ("Getting device list");
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     Constants.MODULE_PATH,
                                                     Constants.KDECONNECT_DEAMON_DEAMON,
                                                     "devices",
                                                     new Variant ("(bb)", 
                                                                  only_reachable,
                                                                  only_paired),
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);                
                Variant i = return_variant.get_child_value (0);                
                devices =  i.dup_strv();                                
            }   
            catch (Error e) {
                debug (e.message);
            }
            debug ("Returning Devices");         
            return devices;
        }  

        protected virtual void discovery_mode (ref DBusConnection conn,
                                               bool acquire = true) {
            try {
                debug (@"Subscribing Discovery mode $acquire");
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                Constants.MODULE_PATH,
                                Constants.KDECONNECT_DEAMON_DEAMON,
                                acquire ? 
                                "acquireDiscoveryMode" :
                                "releaseDiscoveryMode",
                                new Variant ("(s)", 
                                             "Indicator-KDEConnect"),
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);    
            }
            catch (Error e) {
                debug (e.message);
            }            
        }

        /*Signals Subscribind */
        protected virtual uint subscribe_device_added (ref DBusConnection conn) {
            debug ("Subscribing device added");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEAMON,
                                          "deviceAdded",
                                          Constants.MODULE_PATH,
                                          null,
                                          DBusSignalFlags.NONE,
                                          device_added_cb);
        }

        protected virtual uint subscribe_device_removed (ref DBusConnection conn) {
            debug ("Subscribing device removed");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEAMON,
                                          "deviceRemoved",
                                          Constants.MODULE_PATH,
                                          null,
                                          DBusSignalFlags.NONE,
                                          device_removed_cb);
        }

        protected virtual uint subscribe_device_visibility_changed (ref DBusConnection conn) {
            debug ("Subscribing device visibility change");
			return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_DEAMON,
                                          "deviceVisibilityChanged",
                                          Constants.MODULE_PATH,
                                          null,
                                          DBusSignalFlags.NONE,
                                          device_visibility_changed_cb);
        }

        /*Signals Callbacks*/

        protected virtual void device_added_cb (DBusConnection con, 
                                             string sender, 
                                             string object,
                                             string interface, 
                                             string signal_name, 
                                             Variant parameter) {                                             
            string param = parameter.get_child_value (0).get_string ();
            var path = Constants.MODULE_PATH+param;
            add_device (path);
            device_added (path);

            debug ("Device Added");
        }

        protected virtual void device_removed_cb (DBusConnection con, 
                                               string sender, 
                                               string object,
                                               string interface, 
                                               string signal_name, 
                                               Variant parameter) {
            string param = parameter.get_child_value (0).get_string ();
            var path = Constants.MODULE_PATH+param;
            remove_device (path);
            device_removed (path);

            debug ("Device Removed");
        }

        protected virtual void device_visibility_changed_cb (DBusConnection con,
                                                             string sender, 
                                                             string object,
                                                             string interface, 
                                                             string signal_name, 
                                                             Variant parameter) {
            string sring_param = parameter.get_child_value (0).get_string ();
            bool bool_param = parameter.get_child_value (1).get_boolean ();
        
            distribute_visibility_changes (sring_param, bool_param);
            device_visibility_changed (sring_param, bool_param);

            debug ("Device Visibility change");
        }

        protected virtual void pairing_requests_changed_cb (DBusConnection con, 
                                                         string sender, 
                                                         string object,
                                                         string interface, 
                                                         string signal_name, 
                                                         Variant parameter) {
            distribute_pairing_requests_changes ();

            debug ("Pairing Request");
        }

        /*Signals */
        public signal void device_added (string path);
        public signal void device_removed (string path);
        public signal void device_visibility_changed (string path, bool visible);
        public signal void distribute_pairing_requests_changes ();
    }
}
