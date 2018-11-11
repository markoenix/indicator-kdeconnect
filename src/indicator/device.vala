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

        private Gtk.MenuItem info_item;

        private Gtk.MenuItem broswe_item;
        private Gtk.Menu broswe_items_sub_menu;
        private Gtk.MenuItem broswe_items;
        private Gtk.MenuItem share_files_item;
        private Gtk.MenuItem share_url_item;

        private Gtk.MenuItem send_sms_item;

        private Gtk.MenuItem ring_item;
        private Gtk.Menu ping_items_sub_menu;
        private Gtk.MenuItem ping_items;

        private Gtk.MenuItem remotekeyboard_item;

        private Gtk.MenuItem accept_pair_item;
        private Gtk.MenuItem reject_pair_item;
        
        private Gtk.MenuItem unpair_pair_item;
        private Gtk.MenuItem request_pair_item;

        private Gtk.SeparatorMenuItem accept_reject_separator;
        private Gtk.SeparatorMenuItem unpair_request_separator;
        private Gtk.SeparatorMenuItem utils_separator;
        private Gtk.SeparatorMenuItem share_separator;
        private Gtk.SeparatorMenuItem telephony_separator;

        public Device (string path) {
            debug (@"Creating indicator for $path");
            this.path = path;
            deviceManager = new DeviceManager(path);

            indicator = new AppIndicator.Indicator (path,
                                                    deviceManager.icon,
                                                    AppIndicator.IndicatorCategory.HARDWARE);
            
            indicator_menu = new Gtk.Menu ();
            indicator.set_menu (indicator_menu);

            /*Info Group */
            name_item = new Gtk.MenuItem.with_label (deviceManager.name);
            name_item.activate.connect (() => {
                var settings = new SettingsDialog ();
                settings.run ();
            });
            indicator_menu.append (name_item); 
            
            info_item = new Gtk.MenuItem ();

            indicator_menu.append (info_item); 
            
            battery_item = new Gtk.MenuItem ();

            battery_item.activate.connect ( () => {
                Utils.run_kdeconnect_settings ();
            });

            indicator_menu.append (battery_item);
            
            /*File Group */
            share_separator = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (share_separator); 

            broswe_item = new Gtk.MenuItem.with_label (_("Browse"));

            broswe_item.activate.connect (() => {
                deviceManager.browse ();
            });

            indicator_menu.append (broswe_item);

            /* */
            broswe_items = new Gtk.MenuItem.with_label (_("Browse"));

            broswe_items_sub_menu = new Gtk.Menu ();

            broswe_items.set_submenu (broswe_items_sub_menu);

            indicator_menu.append (broswe_items);

            build_browse_sub_paths ();
            /* */

            share_files_item = new Gtk.MenuItem.with_label (_("Send File(s)"));

            share_files_item.activate.connect (() => {
                dialog_file_selector ();              
            });

            indicator_menu.append (share_files_item);
            
            share_url_item = new Gtk.MenuItem.with_label (_("Send URL"));

            share_url_item.activate.connect ( () => {
                var send_text_dialog = new SendGenericText (_("Send URL"), _("URL: "));

                send_text_dialog.send_callback.connect ( (url) => {
                    deviceManager._share_url (url);
                });
                
                send_text_dialog.show ();
            });

            indicator_menu.append (share_url_item); 

            /*Telephony Group */
            telephony_separator = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (telephony_separator); 

            send_sms_item = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (send_sms_item); 

            send_sms_item = new Gtk.MenuItem.with_label (_("Send SMS"));

            send_sms_item.activate.connect (() => {
                Utils.run_sms_python (deviceManager.id);
            });

            indicator_menu.append (send_sms_item);  
            
            /*Utils Group */   
            utils_separator = new Gtk.SeparatorMenuItem ();
            indicator_menu.append (utils_separator); 

            ring_item = new Gtk.MenuItem.with_label (_("Find Device"));

            ring_item.activate.connect (() => {
                deviceManager._ring ();
            });

            indicator_menu.append (ring_item);

            ping_items = new Gtk.MenuItem.with_label (_("Ping"));

            ping_items_sub_menu = new Gtk.Menu ();

            ping_items.set_submenu (ping_items_sub_menu);

            indicator_menu.append (ping_items);

            var ping1 = new Gtk.MenuItem.with_label (_("Ping"));

            ping1.activate.connect (() => {
                deviceManager._send_ping ();
            });

            ping_items_sub_menu.append (ping1);

            var ping2 = new Gtk.MenuItem.with_label (_("Ping Message"));

            ping2.activate.connect (() => {
                var send_text_dialog = new SendGenericText (_("Ping Message"), _("Message: "));

                send_text_dialog.send_callback.connect ( (text) => {
                    deviceManager._send_ping (text);
                });

                send_text_dialog.show ();
            });

            ping_items_sub_menu.append (ping2);

            remotekeyboard_item = new  Gtk.MenuItem.with_label (_("Remote Keyboard"));

            remotekeyboard_item.activate.connect ( () => {
                var remote_keyboard_window = new RemoteKeyboardWindow();
                remote_keyboard_window.send_callback.connect ( (key, specialKey, shift, ctrl, alt) => {
                    deviceManager._remote_keyboard (key, specialKey, shift, ctrl, alt);
                });
                remote_keyboard_window.show ();
            });

            indicator_menu.append (remotekeyboard_item);
            
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
                update_battery_item (charge);
            });

            deviceManager.battery_state_changed.connect ((state) => {
                update_battery_item (null, state);
            });

            deviceManager.plugins_changed.connect (() => {
                update_battery_item ();
                update_all_pluggin_items ();
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

            deviceManager.mounted.connect (() => {
                build_browse_sub_paths ();
            });

            deviceManager.unmounted.connect (() => {

            });

            deviceManager.setting_changed.connect ((property) => {
                update_items_based_on_settings (property);
            });

            /*Role updates */
            indicator_menu.show_all ();  

            update_items_based_on_settings ();
            update_info_item ();
            update_indicator_status ();
            update_battery_item ();
            update_pairing_reject_group ();
            update_unpair_request_group ();                           
            update_all_pluggin_items ();            

            debug ("Device Indicator Created");
        }   

        ~Device () {

        }

        private void update_icon_item (string? icon = null) {
            debug ("Set icon to the device");
            indicator.set_icon_full (icon == null ? 
                                     deviceManager.icon : 
                                     icon, 
                                     "indicator-kdeconnect");
        }

        private void update_name_item (string name) {
            debug ("Set icon to the device");
            name_item.label = deviceManager.name;
        }

        private void update_info_item () {   
            debug ("Update Info Item");         
            if (deviceManager.is_reachable) {
                debug (@"Device $path is reachable");         
                if (deviceManager.is_trusted) {
                    debug (@"Device $path is reachable");         
                    info_item.label = _("Device Reachable and Trusted");                   
                }
                else {
                    debug (@"Device $path is not trusted");
                    info_item.label = _("Device Reachable but Not Trusted");     
                }
            } 
            else {
                debug (@"Device $path is not reachable");         
                if (deviceManager.is_trusted) {
                    debug (@"Device $path is trusted");
                    info_item.label = _("Device Trusted but not Reachable");    
                }
            }            
        }

        private void update_battery_item (int? charge = null, 
                                          bool? charging = null) {
            debug (@"Device $path, update_battery_item");
            if (!deviceManager._has_plugin (Constants.PLUGIN_BATTERY)) {
                debug (@"Device $path, has no plugin battery");
                battery_item.visible = false;
                return;
            }
            else {
                debug (@"Device $path, has plugin battery");
                battery_item.visible = true;
            }

            int _charge = -1;
            bool _charging = false;

            if (charge == null)
                _charge = deviceManager.battery_charge;
            else
                _charge = (int)charge;

            if (charging == null) 
                _charging = deviceManager._battery_charging ();            
            else
                _charging = (bool)charging;
            
            battery_item.label = _("Battery : ") + 
                                   "%d%%".printf(_charge);
            
            if (_charging)
                battery_item.label += _(" (charging)");                             
        }

        private void update_indicator_status (bool? visible = null) {            
            if (visible == null)
                visible = deviceManager.is_reachable;                
            
            debug (@"Device $path, status $visible");                 

            if (visible && 
                deviceManager.is_trusted) {                
                indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);                                                                                                        
            }                
            else {
                if (deviceManager._get_property_bool (Constants.SETTINGS_PAIRED_DEVICES)) {
                    indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);                                
                }
                else {
                    indicator.set_status (AppIndicator.IndicatorStatus.PASSIVE);                                
                }                
            }

            update_icon_item ();
            update_info_item ();
        }

        private void update_all_pluggin_items () {
            debug (@"Device $path, update_all_pluggin_items");

            var _trusted = deviceManager.is_trusted;
            //var _reachable = deviceManager.is_reachable;

            /* Informations */
            update_battery_item ();

            /* Share and SFTP */
            var _share = deviceManager._has_plugin (Constants.PLUGIN_SHARE);
            var _sftp = deviceManager._has_plugin (Constants.PLUGIN_SFTP);

            share_separator.visible = (_share || _sftp) && _trusted; 

            share_files_item.visible = 
            share_url_item.visible = _share && _trusted;  
                                             
            broswe_item.visible =   
            broswe_items.visible = (_sftp && _trusted);
            
            /* Telephony */
            var _telephony = deviceManager._has_plugin (Constants.PLUGIN_TELEPHONY);

            telephony_separator.visible = 
            send_sms_item.visible = _telephony && _trusted;

            /* Utils */
            var _findmyphone = deviceManager._has_plugin (Constants.PLUGIN_FINDMYPHONE);
            var _remotekeyboard = deviceManager._has_plugin (Constants.PLUGIN_REMOTE_KEYBOARD);
            var _ping = deviceManager._has_plugin (Constants.PLUGIN_PING);

            utils_separator.visible = (_findmyphone || _remotekeyboard || _ping) && _trusted;
            ring_item.visible = _findmyphone;
            remotekeyboard_item.visible = _remotekeyboard;
            ping_items.visible = _ping;
        }

        private void update_pairing_reject_group (bool? mode = null) {
            if (mode == null)
                mode = deviceManager.has_pairing_requests;

            request_pair_item.visible = !(bool)mode; 
            
            accept_pair_item.visible = 
            reject_pair_item.visible = mode; 

            accept_reject_separator.visible = mode;
        }

        private void update_unpair_request_group (bool? mode = null) {            
            if (mode == null)
                mode = deviceManager.is_trusted;

            request_pair_item.visible = !((bool)mode);                
            unpair_pair_item.visible =         
            unpair_request_separator.visible = mode;
        }

        private void set_pairing_request_mode (bool has_pairing) {
            if (has_pairing) {
                indicator.set_status (AppIndicator.IndicatorStatus.ATTENTION);   
                update_icon_item (Constants.ICON_ATTENTION);             
            }
            else {
                update_indicator_status ();    
            }

            update_pairing_reject_group (has_pairing);
        }

        private void set_trusted_change_mode (bool trusted) {
            update_unpair_request_group (trusted);
            update_all_pluggin_items ();
        }

        public void visibility_changed (bool visible) {
            debug ("Device visibility change to %s", visible ? "ACTIVE" : "PASSIVE");
            update_indicator_status (visible);
        }

        public void update_items_based_on_settings (string? property = null) {
            if (property != null) {
                switch (property) {
                    case Constants.SETTINGS_PAIRED_DEVICES :
                        update_indicator_status ();                          
                    break;

                    case Constants.SETTINGS_INFO_ITEM :
                        if (deviceManager._get_property_bool (property))
                            info_item.show ();         
                        else
                            info_item.hide ();                          
                    break;

                    case Constants.SETTINGS_BRROWSE_ITEMS :
                        if (deviceManager._get_property_bool (property)) {
                            broswe_items.show ();
                            broswe_item.hide ();
                        }                            
                        else {
                            broswe_items.hide ();
                            broswe_item.show ();
                        }
                    break;
    
                    case Constants.SETTINGS_SEND_URL :
                        if (deviceManager._get_property_bool (property))
                            share_url_item.show ();
                        else
                            share_url_item.hide ();
                    break;

                    case Constants.SETTINGS_SEND_SMS :
                        if (deviceManager._get_property_bool (property))
                            send_sms_item.show ();
                        else    
                            send_sms_item.hide ();
                    break;
    
                    case Constants.SETTINGS_FIND_PHONE :
                        if (deviceManager._get_property_bool (property))
                            ring_item.show ();
                        else    
                            ring_item.hide ();
                    break;

                    case Constants.SETTINGS_PING_ITEMS :
                        if (deviceManager._get_property_bool (property))
                            ping_items.show ();
                        else
                            ping_items.hide ();
                    break;

                    case Constants.SETTINGS_REMOTE_KEYBOARD :
                        if (deviceManager._get_property_bool (property))
                            remotekeyboard_item.show ();
                        else
                            remotekeyboard_item.hide ();
                    break;
                }
            }
            else {
                if (deviceManager._get_property_bool (Constants.SETTINGS_PAIRED_DEVICES))
                    update_indicator_status ();

                if (deviceManager._get_property_bool (Constants.SETTINGS_INFO_ITEM))
                    info_item.show ();         
                else
                    info_item.hide ();

                if (deviceManager._get_property_bool (Constants.SETTINGS_BRROWSE_ITEMS)) 
                {
                    broswe_items.show ();
                    broswe_item.hide ();
                }
                else {
                    broswe_item.show ();
                    broswe_items.hide ();
                }

                if (deviceManager._get_property_bool (Constants.SETTINGS_SEND_URL))
                    share_url_item.show ();
                else
                    share_url_item.hide ();
                    
                if (deviceManager._get_property_bool (Constants.SETTINGS_SEND_SMS))
                    send_sms_item.show ();
                else    
                    send_sms_item.hide ();
                
                if (deviceManager._get_property_bool (Constants.SETTINGS_FIND_PHONE))
                    ring_item.show ();
                else    
                    ring_item.hide ();

                if (deviceManager._get_property_bool (Constants.SETTINGS_PING_ITEMS))
                    ping_items.show ();
                else
                    ping_items.hide ();

                if (deviceManager._get_property_bool (Constants.SETTINGS_REMOTE_KEYBOARD))
                    remotekeyboard_item.show ();
                else
                    remotekeyboard_item.hide ();                
            }
        }

        private async void build_browse_sub_paths () {
            if (!deviceManager.is_sftp_mounted) {
                deviceManager.mount_sftp ();

                //TODO: Por isto numa tread
                // Thread.usleep (500);
                Timeout.add (1000, ()=> { 
                    return false;
                });
            }

            var directories = deviceManager._get_directories();

            if(directories.length () > 0) {
                directories.@foreach ( (pair) => {
                    debug ("%s, %s", pair.get_first (),
                                     pair.get_secound ());

                    var tmpMenuItem = new Gtk.MenuItem.with_label (pair.get_first ());
                    
                    tmpMenuItem.activate.connect ( () => {
                        deviceManager.browse (pair.get_secound ());
                    });
                    
                    broswe_items_sub_menu.append (tmpMenuItem);
                });
            }            
        }

        private void dialog_file_selector () {
            var chooser = new Gtk.FileChooserDialog (_("Select file(s)"),
               					                     null,
               					                     Gtk.FileChooserAction.OPEN,
               					                     _("Cancel"),
               					                     Gtk.ResponseType.CANCEL,
               					                     _("Select"),
               					                     Gtk.ResponseType.OK);

            chooser.select_multiple = true;
                
            if (chooser.run () == Gtk.ResponseType.OK) {
                SList<string> uris = chooser.get_uris ();
	            uris.@foreach ( (item) => {
        	        deviceManager._share_url (item);
	            });
            }
              
            chooser.close ();  
        }

        public bool equals_path (string path) {
            return this.path == path;
        }

        public bool equals_id (string path) {
            return this.deviceManager.id == path;
        }
    }
}
