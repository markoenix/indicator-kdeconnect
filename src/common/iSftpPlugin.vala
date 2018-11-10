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
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path+"/sftp",
                                                     Constants.KDECONNECT_DEAMON_SFTP,
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
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/sftp",
                                Constants.KDECONNECT_DEAMON_SFTP,
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
            debug (@"Device $path, mount");
        }
                
        protected virtual void unmount (ref DBusConnection conn,
                                        string path) {
            try {
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/sftp",
                                Constants.KDECONNECT_DEAMON_SFTP,
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
            debug (@"Device $path, mount");
        }
                      
        protected virtual bool start_browsing (ref DBusConnection conn,
                                               string path) {
            var return_value = false;            
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path+"/sftp",
                                                     Constants.KDECONNECT_DEAMON_SFTP,
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
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path+"/sftp",
                                                     Constants.KDECONNECT_DEAMON_SFTP,
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
            debug (@"Device $path, mount point $return_value");
            return return_value;  
        }

        protected virtual bool is_mounted (ref DBusConnection conn,
                                           string path) {
            var return_value = false;
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path+"/sftp",
                                                     Constants.KDECONNECT_DEAMON_SFTP,
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
            debug (@"Device $path, mount point %s", return_value.to_string ());
            return return_value;
        }

        protected virtual Variant get_directories (ref DBusConnection conn,
                                                   string path) {
            debug ("Getting Directories");
            Variant return_value = null;
            try {
                var return_variant = conn.call_sync (Constants.KDECONNECT_DEAMON,
                                                     path+"/sftp",
                                                     Constants.KDECONNECT_DEAMON_SFTP,
                                                     "getDirectories",
                                                     null,
                                                     null,
                                                     DBusCallFlags.NONE,
                                                     -1,
                                                     null);		        
                
                Variant variant = return_variant.get_child_value (0);
                
                return_value = variant;
            } catch (Error e) {
            	message (e.message);
            }        

            return return_value;
        }

        
        public signal void mounted ();
        public signal void unmounted ();
    }
}
