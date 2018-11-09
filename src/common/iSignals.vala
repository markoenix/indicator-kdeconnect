/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface ISignals : Object {
        public virtual void void_signal_cb (DBusConnection con, 
                                            string sender, 
                                            string object,
                                            string interface, 
                                            string signal_name, 
                                            Variant parameter) {
            
            debug (@"Signal: $signal_name, Value: None");
        }

        public virtual void boolean_signal_cb (DBusConnection con, 
                                               string sender,
                                               string object,
                                               string interface,
                                               string signal_name,
                                               Variant parameter) {
            bool param = parameter.get_child_value (0).get_boolean ();
            debug (@"Signal: $signal_name, Value: $param");
        }

        public virtual void string_signal_cb (DBusConnection con, 
                                              string sender,
                                              string object,
                                              string interface,
                                              string signal_name,
                                              Variant parameter) {
            string param = parameter.get_child_value (0).get_string ();
            debug (@"Signal: $signal_name, Value: $param");
        }                               
        
        public virtual void int32_signal_cb (DBusConnection con, 
                                             string sender, 
                                             string object,
                                             string interface, 
                                             string signal_name, 
                                             Variant parameter) {
            int param = parameter.get_child_value (0).get_int32 ();
            debug (@"Signal: $signal_name, Value: $param");
        }
    }
}
