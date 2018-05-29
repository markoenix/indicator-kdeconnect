/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface ISftp : Object {
        protected virtual bool mount_and_wait (ref DBusConnection conn,
                                               string path) {
            var return_value = false;            
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path+"/sftp",
                                                     "org.kde.kdeconnect.device.sftp",
                                                     "mountAndWait",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);

                Variant val = return_variant.get_child_value (0);
                return_value = val.get_boolean ();
            } 
            catch (Error e) {
                debug (e.message);
            }          
            debug ("Device %s, mount and wait", return_value.to_string ());
            return return_value;  
        }

        protected virtual void mount (ref DBusConnection conn,
                                      string path) {            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/sftp",
                                "org.kde.kdeconnect.device.sftp",
                                "mount",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);
            } 
            catch (Error e) {
                debug (e.message);
            }          
            debug ("Device %s, mount", path);  
        }
                
        protected virtual void unmount (ref DBusConnection conn,
                                        string path) {
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/sftp",
                                "org.kde.kdeconnect.device.sftp",
                                "unmount",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);                
            } 
            catch (Error e) {
                debug (e.message);
            }          
            debug ("Device %s, mount", path);            
        }
                      
        protected virtual bool start_browsing (ref DBusConnection conn,
                                               string path) {
            var return_value = false;            
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path+"/sftp",
                                                     "org.kde.kdeconnect.device.sftp",
                                                     "startBrowsing",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);

                Variant val = return_variant.get_child_value (0);
                return_value = val.get_boolean ();
            } 
            catch (Error e) {
                debug (e.message);
            }          
            debug ("Device %s, isMounted", return_value.to_string ());
            return return_value;  
        }
                              
        protected virtual string mount_point (ref DBusConnection conn,
                                              string path) {
            var return_value = "";            
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path+"/sftp",
                                                     "org.kde.kdeconnect.device.sftp",
                                                     "mountPoint",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);

                Variant val = return_variant.get_child_value (0);
                return_value = val.get_string ();
            } 
            catch (Error e) {
                debug (e.message);
            }          
            debug ("Device %s, mount point %s", path, return_value);
            return return_value;  
        }

        protected virtual bool is_mounted (ref DBusConnection conn,
                                           string path) {
            var return_value = false;
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path+"/sftp",
                                                     "org.kde.kdeconnect.device.sftp",
                                                     "isMounted",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);
                Variant val = return_variant.get_child_value (0);
                return_value = val.get_boolean ();
            } catch (Error e) {
                message (e.message);
            }
            debug ("Device %s, mount point %s", path, return_value.to_string ());
            return return_value;
        }

        protected virtual SList<Pair<string,string>> get_directories (ref DBusConnection conn,
                                                                      string path) {
            var directories = new SList<Pair<string,string>>();
            try {
                var return_variant = conn.call_sync ("org.kde.kdeconnect",
                                                     path+"/sftp",
                                                     "org.kde.kdeconnect.device.sftp",
                                                     "getDirectories",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);		        
                
                Variant variant = return_variant.get_child_value (0);
                VariantIter iter = variant.iterator ();

                Variant? val = null;
                string? key = null;

	            while (iter.next ("{sv}", ref key, ref val))
                    directories.append (new Pair<string,string>(key, val.dup_string ()));	
                    
                message ("Founded Directories %d", (int)directories.length ());                        
            } catch (Error e) {
            	message (e.message);
            }        
            return directories;
        }

        
        public signal void mounted ();
        public signal void unmounted ();
    }
}