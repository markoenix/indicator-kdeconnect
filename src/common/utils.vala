/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {  
    public class Pair<F,S> : Object {
        private F _first;
        private S _secound;

        public Pair(F first, S secound) {
            this._first = first;
            this._secound = secound;
        }

        public void set_first(F first) {
            this._first = first;
        }

        public S get_first() {
            return this._first;
        }

        public void set_secound(F secound) {
            this._secound = secound;
        }

        public S get_secound() {
            return this._secound;
        }
    }

    public class Utils : Object {    
        public static bool run_kdeconnect_deamon () {
            var return_value = false;

            var kdeconnect_path = GLib.Environment.get_system_config_dirs()[0]+
            			                           "/autostart/kdeconnectd.desktop";

            string std_out;

            try{
		        Process.spawn_sync (null,
				                    new string[]{"grep","Exec",kdeconnect_path},
				                    null,
				                    SpawnFlags.SEARCH_PATH,
				                    null,
				                    out std_out,
				                    null,
				                    null);
            } 
            catch (Error e){
		        debug (e.message);
            }

            if (std_out != null)
            {
                File f = File.new_for_path (std_out.substring (5));
                if (f.query_exists ()) {
                    try {
                        Process.spawn_command_line_sync (f.get_path ());
                        return_value = true;
                    } 
                    catch (Error e) {
                        debug (e.message);
                    }
                }
            }   

            return return_value;
        }    
    
        public static bool open_file (string path) {            
            try {
                var file = File.new_for_path (path);
                var handler = file.query_default_handler ();
                var list = new List<File> ();
                list.append (file);
                return handler.launch (list, 
                                       null);                
            } 
            catch (Error e) {
                debug (e.message);
            }
            return false;
        }

        public static void run_sms_python (string device_id) {
            try{
                Process.spawn_async (null,
                                     new string[]{Config.PACKAGE_DATADIR+
                                                  "/"+
                                                  Config.PACKAGE_NAME+
                                                  "/sms.py",
                                                  "-d",
                                                  device_id},
                                     null,
                                     SpawnFlags.SEARCH_PATH,
                                     null,
                                     null);
            } 
            catch (Error e) {
                debug (e.message);
            }
        }

        public static void run_settings () {
            try{
                Process.spawn_async (null,
                                     new string[]{"settings-ind-kdec"},
                                     null,
                                     SpawnFlags.SEARCH_PATH,
                                     null,
                                     null);
            } 
            catch (Error e) {
                debug (e.message);
            }
        }

        public static SList<Pair<string,string>> unvariant_data (Variant variant) {
            var directories = new SList<Pair<string,string>>();
            
            VariantIter iter = variant.iterator ();                
                
            Variant? val = null;
            string? key = null;

	        while (iter.next ("{sv}", ref key, ref val)) {
                if (val != null && key != null)
                    directories.append (new Pair<string,string>(val.dup_string (), 
                                                                key));
            }                    
                        
            return directories;
        }

        public static int serialize_folders (string id, string data) {
            var return_value = 0;				    
            try {
                var file = File.new_for_path (GLib.Environment. get_user_data_dir()+
                                              "/indicator-kdeconnect/"+                                              
                                              "folders_"+
                                              id+
                                              ".json");
	
                if (file.query_exists ()) {
                    debug ("File '%s' exists exist.\n", file.get_path ());
                    file.delete ();                    
                }
                else {
                    debug ("File doesn't exist '%s'\n", file.get_path ());
                }
        
                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
        
                uint8[] _byte_data = data.data;
                long written = 0;
                while (written < _byte_data.length) {
                    written += dos.write (_byte_data[written:_byte_data.length]);
                }      
                return_value = (int)written;          
            }
            catch (Error e) {
                debug (e.message);
            }
            return return_value;
        }

        public static string unserialize_folders (string id) {
            var return_value = "";				    
            try {
                var file = File.new_for_path (GLib.Environment. get_user_data_dir()+
                                              "/indicator-kdeconnect/"+                                              
                                              "folders_"+
                                              id+
                                              ".json");
	
                if (file.query_exists ()) {
                    debug ("File '%s' exists exist.\n", file.get_path ());

                    var dis = new DataInputStream (file.read ());
                    
                    string line;
                    var sb = new StringBuilder ();

                    while ((line = dis.read_line (null)) != null) {
                        sb.append (line);
                    }

                    return_value = sb.str;
                }
                else {
                    debug ("File doesn't exist '%s'\n", file.get_path ());
                }             
            }
            catch (Error e) {
                debug (e.message);
            }
            return return_value;
        }
    }
}