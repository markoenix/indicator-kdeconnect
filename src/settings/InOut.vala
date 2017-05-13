/* Copyright 2017 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace KDEConnectIndicator {
	class InOut{
	private static string visible_devices = "/tmp/devices";

        public static int write_status (string id, string name) {
	    var file = File.new_for_path (visible_devices);

            if (!file.query_exists ()) {
        	message ("File '%s' doesn't exist.\n", file.get_path ());
        	return 1;
    	    }
    	    else {
    	    	message ("File path exist '%s'\n", file.get_path ());
    	    }

    	    StringBuilder sb = new StringBuilder ();

            string name_id = "- "+name+" : "+id;

    	    try {
        	var dis = new DataInputStream (file.read ());

        	string line;

		//If the file contains one reference to this device just igone
        	while ((line = dis.read_line (null)) != null) {
            	      message ("Status found on file %s\n", line);
            	      if (name_id != line)
            	      	sb.append (line+"\n");
            	      else
            	        return 1;
        	}

		//If the file don't have any reference to this write it
        	sb.append (name_id+"\n");

    	    } catch (Error e) {
       		error ("%s", e.message);
    	    }

    	    try {
                if (file.query_exists ()) {
                   file.delete ();
                }

                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

                uint8[] data = sb.str.data;
                long written = 0;
                while (written < data.length) {
                   written += dos.write (data[written:data.length]);
                }
            } catch (Error e) {
        	message ("%s\n", e.message);
        	return 1;
    	    }

	    return 0;
        }

        public static int delete_status (string id, string name) {
	    var file = File.new_for_path (visible_devices);

            if (!file.query_exists ()) {
        	message ("File '%s' doesn't exist.\n", file.get_path ());
        	return 1;
            }
    	    else {
    	    	message ("File path exist '%s'\n", file.get_path ());
    	    }

    	    StringBuilder sb = new StringBuilder ();

            string name_id = "- "+name+" : "+id;

    	    try {
        	var dis = new DataInputStream (file.read ());

        	string line;

        	while ((line = dis.read_line (null)) != null) {
            	      message ("Delete status found on file %s\n", line);
            	      if (line != name_id)
		      	sb.append (line+"\n");
        	}

    	    } catch (Error e) {
       		error ("%s", e.message);
    	    }

    	    try {
                if (file.query_exists ())
                   file.delete ();

                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

                uint8[] data = sb.str.data;
                long written = 0;
                while (written < data.length) {
                   written += dos.write (data[written:data.length]);
                }
            } catch (Error e) {
        	message ("%s\n", e.message);
    	    }

	    return 0;
        }
        }
}
