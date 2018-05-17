/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Utils;
using Dialogs;

namespace KDEConnectIndicator {
    public class DeviceIndicator {
        public string path;
        private Device device;
        private Gtk.Menu menu;
        private AppIndicator.Indicator indicator;
        private Gtk.MenuItem name_item;
        private Gtk.MenuItem battery_item;
        private Gtk.MenuItem status_item;
        private Gtk.MenuItem browse_item;
        private Gtk.Menu browse_submenu_item;     
        private Gtk.MenuItem send_item;
        private Gtk.MenuItem send_url_item;
        private Gtk.MenuItem ring_item;
        private Gtk.MenuItem sms_item;
        private Gtk.MenuItem accept_pair_item;
        private Gtk.MenuItem reject_pair_item;
        private Gtk.MenuItem request_pair_item;
        private Gtk.MenuItem unpairing_item;        
        private Gtk.SeparatorMenuItem separator;
        private Gtk.SeparatorMenuItem separator2;
        private Gtk.SeparatorMenuItem separator3;        
        private Gtk.SeparatorMenuItem separator4;
        private ulong handler_broswer;

        public DeviceIndicator (string path) {
            this.path = path;
            device = new Device (path);
            menu = new Gtk.Menu ();

            indicator = new AppIndicator.Indicator (path,
                    				                device.icon,
                                                    AppIndicator.IndicatorCategory.HARDWARE);
                                                    
            name_item = new Gtk.MenuItem ();
            menu.append (name_item);

            name_item.activate.connect (() => {
                try {
	    	        Process.spawn_async (null,
	    	     	                 	 new string[]{"indicator-kdeconnect-settings"},
	    	     			             null,
	    	     			             SpawnFlags.SEARCH_PATH,
	    	     			             null,
	    	     			             null);
	    	    } catch (Error	e) {
	    	        message (e.message);
                }
	        });

            battery_item = new Gtk.MenuItem();
            menu.append (battery_item);
            
            //  battery_item.activate.connect (() => {
	    	    
	        //  });
            
            status_item = new Gtk.MenuItem ();
            menu.append (status_item);
            
            status_item.activate.connect (() => {
		        try {
                    Process.spawn_async (null,
                            			 new string[]{"kcmshell5", "kcm_kdeconnect"},
					                     null,
					                     SpawnFlags.SEARCH_PATH,
					                     null,
					                     null);
                } catch (Error e) {
                    message (e.message);
                }
	        });
            
            separator4 = new Gtk.SeparatorMenuItem ();
            menu.append (separator4);

            browse_item = new Gtk.MenuItem.with_label (_("Browse device"));                                   
            menu.append (browse_item); 
            
            this.handler_broswer = browse_item.activate.connect (() => {                                        
                device.browse ();
            });

            update_broswe_items ();          
            
            send_item = new Gtk.MenuItem.with_label (_("Send file(s)"));            
            menu.append (send_item);

            send_item.activate.connect (() => {
                var chooser = new Gtk.FileChooserDialog (_("Select file(s)"),
                					 null,
                					 Gtk.FileChooserAction.OPEN,
                					 _("Cancel"),
                					 Gtk.ResponseType.CANCEL,
                					 _("Select"),
                					 Gtk.ResponseType.OK);
                
                chooser.select_multiple = true;
                
                if (chooser.run () == Gtk.ResponseType.OK) {
                    SList<string> urls = chooser.get_uris ();

		            urls.@foreach ((item) => {
		    	        device.send_file(item);
		            });
                }
                
                chooser.close ();
            });

            send_url_item = new  Gtk.MenuItem.with_label (_("Send URL"));                    
            menu.append (send_url_item);
                
            send_url_item.activate.connect (() => {
                var send_url_item_dialog = new Dialogs.SendURL(this.device.send_file);
                send_url_item_dialog.show ();
            });                        
                                
            separator = new Gtk.SeparatorMenuItem ();
            menu.append (separator);
                        
            sms_item = new Gtk.MenuItem.with_label (_("Send SMS"));
            menu.append (sms_item);

            sms_item.activate.connect (() => {
            	try{
		            Process.spawn_async (null,
		    		                     new string[]{"/usr/share/indicator-kdeconnect/Sms.py",
					                                  "-d",
					                                  device.id},
				                         null,
				                         SpawnFlags.SEARCH_PATH,
				                         null,
				                         null);
	    	    } catch (Error e) {
		            message (e.message);
            	}
            });
            
            separator2 = new Gtk.SeparatorMenuItem ();
            menu.append (separator2);
            
            ring_item = new Gtk.MenuItem.with_label (_("Find my phone"));
            menu.append (ring_item);

            ring_item.activate.connect (() => {
		        device.find_my_phone ();
	        });
            
            separator3 = new Gtk.SeparatorMenuItem ();
            menu.append (separator3);

            accept_pair_item = new Gtk.MenuItem.with_label (_("Accept pairing"));
            menu.append (accept_pair_item);

            accept_pair_item.activate.connect (() => {
                device.accept_pairing ();
            });

            reject_pair_item = new Gtk.MenuItem.with_label (_("Reject pairing"));
            menu.append (reject_pair_item);

            reject_pair_item.activate.connect (() => {
                device.reject_pairing ();
            });

            request_pair_item = new Gtk.MenuItem.with_label (_("Request pairing"));
            menu.append (request_pair_item);

            request_pair_item.activate.connect (() => {
                device.request_pair ();
            });
            
            unpairing_item = new Gtk.MenuItem.with_label (_("Unpair"));
            menu.append (unpairing_item);            
            
            unpairing_item.activate.connect (() => {
                device.unpair ();
            });	        

            //---------------------------------------------------------------//

            device.charge_changed.connect ((charge) => {
                update_battery_item ();
            });
            
            device.state_changed.connect ((state) => {
                update_battery_item ();
                update_status_item ();
                update_all_items ();
            });
            
            device.pairing_error.connect (() => {
                update_all_items ();                
                update_visibility ();
                update_status_item ();
            });
            
            device.plugins_changed.connect (() => {                
                update_all_items ();
            });
            
            device.reachable_status_changed.connect (() => {
                update_visibility ();
                update_all_items ();                
                update_icon_item ();
                update_status_item ();
            });
            
            device.trusted_changed.connect ((trusted) => {
                //  if (!trusted)
                //      update_visibility ();
                update_visibility ();
                update_all_items ();
                update_status_item ();
                update_icon_item ();
            }); 
            
            device.settings_changed.connect ((item) => {
                switch (item) {
                    case "list-device-dir":
                        update_broswe_items ();
                    break;
                     
                    case "show-send-url":
                        send_url_item.set_visible (device.show_send_url);
                    break;
                } 
            });

            device.mounted.connect ( () => {
                update_broswe_items ();
            });   
            
            device.unmounted.connect ( () => {
                update_broswe_items ();
            });   

            device.name_changed.connect ( (name) => {
                update_name_item (name);
            });

            device.has_pairing_requests_Changed.connect ( () => {
                update_all_items ();
            });

            menu.show_all ();
            
            update_name_item ();
            update_visibility ();            
            update_battery_item ();
            update_status_item ();
            update_all_items ();
        
            send_url_item.set_visible (device.show_send_url);

            indicator.set_menu (menu);
        }                
        
        public void device_visibility_changed (bool visible) {
            message ("%s visibilitiy changed to %s", device.name, visible?"true":"false");
            update_visibility ();
            update_name_item ();            
            update_battery_item ();
            update_status_item ();
            update_all_items ();
            update_icon_item ();
        }

        private void update_visibility () {
            if (!device.is_reachable)
                indicator.set_status (AppIndicator.IndicatorStatus.PASSIVE);
            else
                indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);
        }
        
        private void update_name_item (string? name = null) {
            if (name != null)
                name_item.label = name;
            else
                name_item.label = device.name;
        }

        private void update_icon_item() {
	        indicator.set_icon_full (device.icon, "");
	    }
        
        private void update_battery_item () {
            battery_item.visible = device.is_trusted && 
                                   device.is_reachable && 
                                   device.has_plugin ("kdeconnect_battery");

            battery_item.label = _("Battery : ") + "%d%%".printf(device.battery);
            
            if (device.is_charging ())
                battery_item.label += _(" (charging)");
        }
        
        private void update_status_item () {
            if (device.is_reachable) {
                if (device.is_trusted) {
                    status_item.label = _("Device Reachable and Trusted");
                    try {Utils.InOut.write_status (device.id, device.name);}
                    catch (Error e){message(e.message);}                    
                }
                else {
                    status_item.label = _("Device Reachable but Not Trusted");
                    try {Utils.InOut.delete_status (device.id, device.name);}
                    catch (Error e){message(e.message);}       
                }
            } 
            else {
                if (device.is_trusted) {
                    status_item.label = _("Device Trusted but not Reachable");
                    try {Utils.InOut.delete_status (device.id, device.name);}
                    catch (Error e){message(e.message);}       
                }
                else {
                    status_item.label = _("Device Not Reachable and Not Trusted");
                    try {Utils.InOut.delete_status (device.id, device.name);}
                    catch (Error e){message(e.message);}                    
	    	        // is this even posible?
                }
            }
        }
        
        private void update_all_items () {

            if (device.has_pairing_request) {
                reject_pair_item.visible = accept_pair_item.visible = true;

                battery_item.visible = request_pair_item.visible =  unpairing_item.visible = 
                browse_item.visible = send_item.visible = sms_item.visible = ring_item.visible = false;
            }
            else {
                reject_pair_item.visible = accept_pair_item.visible = false;

                var trusted = device.is_trusted;
                var reachable = device.is_reachable;

                request_pair_item.visible = !trusted;
                unpairing_item.visible = trusted;

                battery_item.visible = trusted && device.has_plugin ("kdeconnect_battery");
                battery_item.sensitive = reachable;
    
                browse_item.visible = trusted && device.has_plugin ("kdeconnect_sftp");
                browse_item.sensitive = reachable;
    
                send_item.visible = send_url_item.visible = trusted && device.has_plugin ("kdeconnect_share");
                send_item.sensitive = send_url_item.sensitive = reachable;
    
                sms_item.visible = trusted && device.has_plugin("kdeconnect_telephony");
                sms_item.sensitive = reachable;
    
                ring_item.visible = trusted && device.has_plugin ("kdeconnect_findmyphone");
                ring_item.sensitive = reachable;
            }             
            
            separator.visible = browse_item.visible || send_item.visible || send_url_item.visible;
            separator2.visible = sms_item.visible;
            separator3.visible = ring_item.visible;           
        }        

        private void update_broswe_items () {
            message("signal received");            
            var directories = device.get_directories();   

            if(device.to_list_dir && directories.length > 0) {  
                browse_item.disconnect (this.handler_broswer);                              
                browse_submenu_item = new Gtk.Menu();                            
                browse_item.set_submenu (browse_submenu_item);   

                for (int i = 0; i < directories.length; i++) {
                    var pair = directories.index (i); 		                        
                    message(pair.get_secound());
                    
                    var tmpMenuItem = new Gtk.MenuItem.with_label (pair.get_secound());                    
                
                    tmpMenuItem.activate.connect (() => {                        
                        device.browse (pair.get_first ());
                    });

                    browse_submenu_item.append (tmpMenuItem);
                }	    
                                
                browse_submenu_item.show_all ();                  
            }
            else {                
                if(this.handler_broswer == 0) {
                    this.handler_broswer = browse_item.activate.connect (() => {                                        
                        device.browse ();
                    });
                }

                browse_item.set_submenu (null);
            }

            browse_item.show_all();
        } 
    }
}
