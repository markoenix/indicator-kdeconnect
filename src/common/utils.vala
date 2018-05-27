/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {    
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
	        } catch (Error e){
		        message (e.message);
            }

            if (std_out != null)
            {
                File f = File.new_for_path (std_out.substring (5));
                if (f.query_exists ()) {
                    try {
                        Process.spawn_command_line_sync (f.get_path ());
                        return_value = true;
                    } catch (Error e) {
                        message (e.message);
                    }
                }
            }   

            return return_value;
        }    
                
    }
}