/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IKDEConnectManager : Object {
        //  public abstract string[] devices (bool only_reachable = false);

        //  public abstract void add_device (string path);
        //  public abstract void remove_device (string path);
        //  public abstract void distribute_visibility_changes (string path, bool visible);
        //  public abstract void distribute_pairing_requests_changes (bool changed);       

        //  public virtual void device_added_cb (DBusConnection con, 
        //                                       string sender, 
        //                                       string object,
        //                                       string interface, 
        //                                       string signal_name, 
        //                                       Variant parameter) {                                             
        //      string param = parameter.get_child_value (0).get_string ();
        //      var path = "/modules/kdeconnect/devices/"+param;            
        //      add_device (path);
        //      device_added (path);
        //  }

        public virtual void device_removed_cb (DBusConnection con, 
                                               string sender, 
                                               string object,
                                               string interface, 
                                               string signal_name, 
                                               Variant parameter) {
            string param = parameter.get_child_value (0).get_string ();
            var path = "/modules/kdeconnect/devices/"+param;
            remove_device (path);
            device_removed (path);
        }

        public virtual void device_visibility_changed_cb (DBusConnection con, 
                                                          string sender, 
                                                          string object,
                                                          string interface, 
                                                          string signal_name, 
                                                          Variant parameter) {
            string sring_param = parameter.get_child_value (0).get_string ();
            bool bool_param = parameter.get_child_value (1).get_boolean ();
        
            distribute_visibility_changes (sring_param, bool_param);
            device_visibility_changed (sring_param, bool_param);
        }

        public virtual void pairing_requests_changed_cb (DBusConnection con, 
                                                         string sender, 
                                                         string object,
                                                         string interface, 
                                                         string signal_name, 
                                                         Variant parameter) {            

            distribute_pairing_requests_changes ();
        }

        public signal void device_added (string path);
        public signal void device_removed (string path);
        public signal void device_visibility_changed (string path, bool visible);
        public signal void distribute_pairing_requests_changes ();
    }
}