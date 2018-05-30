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

        //  private static void restart () {
		//  	string std_out;

		//  	message ("Getting PID to restart");

        //      try {
		//  	    Process.spawn_sync (null,
		//  	              			new string[]{"pidof",
		//  	     	         		             "indicator-kdeconnect"},
		//  	    					null,
		//  	    					SpawnFlags.SEARCH_PATH,
		//  	    					null,
		//  	                        out std_out,
		//  	    					null,
		//  	    					null);
		//  	} 
		//  	catch (Error e) {
		//  	    debug (e.message);
		//  	}

		//  	if (std_out != ""){
       	//  		message("Killing PID");

    	//  		int pid = int.parse(std_out);

    	//  		try {
	    //  	    	Process.spawn_sync (null,
	    //      		    	        	new string[]{"kill",
		//      	                    	pid.to_string()},
		//  	    			        	null,
		//  	    			        	SpawnFlags.SEARCH_PATH,
		//  	    			        	null,
		//  	                        	out std_out,
		//  	    				    	null,
		//  	    				    	null);
		//  		} 
		//  		catch (Error e) {
		//  	    	debug (e.message);
		//  		}
			
		//  		message("Restart process");

        //      	try {
		//          	Process.spawn_async (null,
		//                  			 	new string[]{"indicator-kdeconnect"},
		//  		         			 	null,
		//  		        			 	SpawnFlags.SEARCH_PATH,
		//  			                 	null,
		//  		                     	null);
		//  		} 
		//  		catch (Error e) {
		//      		debug (e.message);
		//  		} 
		//  	}       	
		//  }
    }
}