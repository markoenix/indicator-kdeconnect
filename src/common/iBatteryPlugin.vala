/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IBattery : Object,
                                ISignals {
        protected int charge (ref DBusConnection conn, 
                              string path) {
            var return_value = -1;                            
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path,
                                                     Constants.KDECONNECT_DEAMON_BATTERY,
                                                     "charge",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                Variant i = return_variant.get_child_value (0);               
                return_value = i.get_int32 ();
            } 
            catch (Error e) {
                debug (e.message);
            }
            debug (@"Device $path, charge $return_value");
            return return_value;
        }
                 
        protected bool is_charging (ref DBusConnection conn, 
                                    string path) {                    
            var return_value = false;
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path,
                                                     Constants.KDECONNECT_DEAMON_BATTERY,
                                                     "isCharging",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                Variant i = return_variant.get_child_value (0);                                
                return_value = i.get_boolean ();
            } catch (Error e) {
                debug (e.message);
            }
            debug (@"Device $path, Is charging %s", return_value.to_string ());
            return return_value;
        }

        protected virtual uint subscribe_battery_charge_changed (ref DBusConnection conn, 
                                                                 string path) {
            debug ("Subscribing battery charge");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_BATTERY,
                                          "chargeChanged",
                                          path,
                                          null,
                                          DBusSignalFlags.NONE,
                                          int32_signal_cb);
        }

        protected virtual uint subscribe_battery_state_changed (ref DBusConnection conn, 
                                                                string path) {
            debug ("Subscribing battery state");
            return conn.signal_subscribe (Constants.KDECONNECT_DEAMON,
                                          Constants.KDECONNECT_DEAMON_BATTERY,
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
            debug (@"Battery Signal: $signal_name, Value: $param");
            battery_charge_changed (param);
        }

        protected void boolean_signal_cb (DBusConnection con,
                                          string sender,
                                          string object,
                                          string interface,
                                          string signal_name,
                                          Variant parameter) {
            bool param = parameter.get_child_value (0).get_boolean ();
            debug (@"Battery Signal: $signal_name, Value: %s", param.to_string ());
            battery_state_changed (param);
        }

        public signal void battery_charge_changed (int charge);
        public signal void battery_state_changed (bool state);  
    }
}
