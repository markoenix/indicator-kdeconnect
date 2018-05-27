/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IBattery : Object, ISignals {
        protected int charge (ref DBusConnection conn, 
                              string path) {
            var return_value = -1;                            
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
               
                return_value = i.get_int32 ();
            } 
            catch (Error e) {
                message (e.message);
            }
          return return_value;
        }         
        protected bool is_charging (ref DBusConnection conn, 
                                    string path) {                    
            var return_value = false;
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
                                
                return_value = i.get_boolean ();
            } catch (Error e) {
                message (e.message);
            }
            return return_value;
        }

        protected virtual uint subscribe_battery_charge_changed (ref DBusConnection conn, 
                                                                 string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device.battery",
                                          "chargeChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          int32_signal_cb);
        }

        protected virtual uint subscribe_battery_state_changed (ref DBusConnection conn, 
                                                                string path) {
            return conn.signal_subscribe ("org.kde.kdeconnect",
                                          "org.kde.kdeconnect.device.battery",
                                          "stateChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          boolean_signal_cb);
        }

        protected void int32_signal_cb (DBusConnection con, 
                                        string sender, 
                                        string object,
                                        string interface, 
                                        string signal_name, 
                                        Variant parameter) {
            int param = (int)parameter.get_child_value (0).get_int32 ();
            debug ("Battery Signal: %s, Value: %d", signal_name, param);
            battery_charge_changed (param);
        }

        protected void boolean_signal_cb (DBusConnection con, 
                                       string sender, 
                                       string object,
                                       string interface, 
                                       string signal_name, 
                                       Variant parameter) {        
            bool param = parameter.get_child_value (0).get_boolean ();
            debug ("Battery Signal: %s, Value: %s", signal_name, param.to_string ());        
            battery_state_changed (param);
        }

        public signal void battery_charge_changed (int charge);  
        public signal void battery_state_changed (bool state);  
    }
}