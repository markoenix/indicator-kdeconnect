/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {  
    public class Device : Object {
        private string path;
        private DeviceManager deviceManager;
        private AppIndicator.Indicator indicator;
        
        private Gtk.Menu indicator_menu;

        private Gtk.MenuItem name_item;

        private Gtk.MenuItem battery_item;

        private Gtk.MenuItem accept_pair_item;
        private Gtk.MenuItem reject_pair_item;
        
        private Gtk.MenuItem unpair_pair_item;
        private Gtk.MenuItem request_pair_item;

        private Gtk.SeparatorMenuItem accept_reject_separator;
        private Gtk.SeparatorMenuItem unpair_request_separator;

        public Device (string path) {
            debug ("Creating indicator for %s", path);
            this.path = path;
            deviceManager = new DeviceManager(path);

            indicator = new AppIndicator.Indicator (path,
                                                    deviceManager.icon,
                                                    AppIndicator.IndicatorCategory.HARDWARE);
            
            indicator_menu = new Gtk.Menu ();
            indicator.set_menu (indicator_menu);

            /*Info Group */
            name_item = new Gtk.MenuItem.with_label (deviceManager.name);
            indicator_menu.append (name_item);        

            battery_item = new Gtk.MenuItem ();
            indicator_menu.append (battery_item);  
            
            /*Accept Reject pair Group */
            accept_reject_separator = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (accept_reject_separator);

            accept_pair_item = new Gtk.MenuItem.with_label (_("Accept pairing request"));
            
            accept_pair_item.activate.connect (() => {
                deviceManager._accept_pairing ();
            });
            
            indicator_menu.append (accept_pair_item); 

            reject_pair_item = new Gtk.MenuItem.with_label (_("Reject pairing request"));
            
            reject_pair_item.activate.connect (() => {
                deviceManager._reject_pairing ();
            });

            indicator_menu.append (reject_pair_item); 

            /*Request Reject pair Group */
            unpair_request_separator = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (unpair_request_separator);

            unpair_pair_item = new Gtk.MenuItem.with_label (_("Unpair"));
            
            unpair_pair_item.activate.connect (() => {
                deviceManager._unpair ();
            });
            
            indicator_menu.append (unpair_pair_item); 

            request_pair_item = new Gtk.MenuItem.with_label (_("Request pair"));
            
            request_pair_item.activate.connect (() => {
                deviceManager._request_pair ();
            });

            indicator_menu.append (request_pair_item); 

            /*Connect to signals */
            deviceManager.name_changed.connect ((name) => {
                update_name_item (name);
            });

            deviceManager.battery_charge_changed.connect ((charge) => {
                //update_battery_item (charge);
            });

            deviceManager.battery_state_changed.connect ((state) => {
                //update_battery_itemupdate_battery_item (null, state);
            });

            deviceManager.trusted_status_changed.connect ((trusted) => {
                set_trusted_change_mode (trusted);
            });

            deviceManager.reachable_status_changed.connect ((reachable) => {
                update_indicator_status (reachable);
            });

            deviceManager.has_pairing_requests_changed.connect ((has_pairing) => {
                set_pairing_request_mode (has_pairing);
            });

            /*Role updates */
            indicator_menu.show_all ();  

            update_indicator_status ();
            update_battery_item ();
            update_pairing_reject_group ();
            update_unpair_request_group ();            
        }   

        ~Device () {

        }

        private void update_name_item (string name) {
            name_item.label = deviceManager.name;
        }

        private void update_icon_item() {
            indicator.set_icon_full (deviceManager.icon, 
                                     "indicator-kdeconnect");
        }

        private void update_battery_item (int? charge = null, 
                                          bool? charging = null) {
            if (!deviceManager._has_plugin ("kdeconnect_battery")) {
                battery_item.visible = false;
                return;
            }
            else {
                battery_item.visible = true;
            }

            int _charge = -1;
            bool _charging = false;

            if (charge == null)
                _charge = deviceManager.battery_charge;
            else
                _charge = (int)charge;

            if (charging == null) 
                _charging = deviceManager._battery_charging();            
            else
                _charging = (bool)charging;
            
            battery_item.label = _("Battery : ") + 
                                   "%d%%".printf(_charge);
            
            if (_charging)
                battery_item.label += _(" (charging)");                             
        }

        private void update_pairing_reject_group (bool? mode = null) {
            if (mode == null)
                mode = deviceManager.has_pairing_requests;

            accept_pair_item.visible = 
            reject_pair_item.visible = 
            accept_reject_separator.visible = mode;
        }

        private void update_unpair_request_group (bool? mode = null) {            
            if (mode == null)
                mode = deviceManager.is_trusted;

            request_pair_item.visible = !(bool)mode;                
            unpair_pair_item.visible =         
            unpair_request_separator.visible = mode;
        }

        private void set_pairing_request_mode (bool has_pairing) {
            if (has_pairing) {
                indicator.set_status (AppIndicator.IndicatorStatus.ATTENTION);                
            }
            else {
                update_indicator_status ();    
            }
            update_pairing_reject_group (has_pairing);
        }

        private void set_trusted_change_mode (bool trusted) {
            update_unpair_request_group (trusted);

        }
        
        private void update_indicator_status (bool? visible = null) {
            if (visible == null)
                visible = deviceManager.is_reachable;            

            if (visible)
                indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);
            else
                indicator.set_status (AppIndicator.IndicatorStatus.PASSIVE);
            
            update_icon_item ();
        }

        public void visibility_changed (bool visible) {
            debug ("Device visibility change to %s", visible ? "ACTIVE" : "PASSIVE");
            update_indicator_status (visible);
        }

        public bool equals_path (string path) {
            return this.path == path;
        }

        public bool equals_id (string path) {
            return this.deviceManager.id == path;
        }
    }
}