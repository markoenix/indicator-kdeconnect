/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IDeviceManager : Object {     
        public abstract bool has_plugin (string plugin);           

        public void void_signal_cb (DBusConnection con, 
                                    string sender, 
                                    string object,
                                    string interface, 
                                    string signal_name, 
                                    Variant parameter) {
            switch (signal_name) {
                case "pluginsChanged" :
                    plugins_changed ();
                break;

                case "reachableStatusChanged" :
                    reachable_status_changed ();
                break;

                case "mounted" :
                    mount_status_change (true);
                break;

                case "unmounted" :
                    mount_status_change (false);
                break;

                case "allNotificationsRemoved" :
                    
                break;                    
            }
        }

        public void boolean_signal_cb (DBusConnection con, 
                                       string sender, 
                                       string object,
                                       string interface, 
                                       string signal_name, 
                                       Variant parameter) {
            bool param = parameter.get_child_value (0).get_boolean ();

            switch (signal_name) {
                case "stateChanged" :
                    battery_state_changed (param);
                break;

                case "trustedChanged" :
                    trusted_status_changed (param);
                break;

                case "hasPairingRequestsChanged" :
                    pairing_requests_Changed (param);
                break;
            }
    }

    public void string_signal_cb (DBusConnection con, 
                                  string sender, 
                                  string object,
                                  string interface, 
                                  string signal_name, 
                                  Variant parameter) {
        string param = parameter.get_child_value (0).get_string ();

        switch (signal_name) {
            case "pairingError" :
                pairing_error_changed (param);
            break;

            case "nameChanged" :
                device_name_changed (param);
            break;

            case "notificationPosted" :

            break;

            case "notificationRemoved" :

            break;

            case "notificationUpdated":

            break;
        }
    }
    
    public void int32_signal_cb (DBusConnection con, 
                                     string sender, 
                                     string object,
                                     string interface, 
                                     string signal_name, 
                                     Variant parameter) {            
        
            int param = (int)parameter.get_child_value (0).get_int32 ();

            switch (signal_name) {
                case "chargeChanged" :
                    battery_charge_changed (param);
                break;
            }
        }
        
        public signal void device_name_changed (string name);        
        public signal void battery_charge_changed (int charge);  
        public signal void battery_state_changed (bool state);  
        public signal void trusted_status_changed (bool trusted);
        public signal void reachable_status_changed ();
        public signal void pairing_error_changed (string error);    
        public signal void pairing_requests_Changed (bool hasPairing);    
        public signal void plugins_changed ();        
        public signal void mount_status_change (bool mounted);    
    }
}