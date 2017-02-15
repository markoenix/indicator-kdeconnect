/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace KDEConnectIndicator {
	public class DeviceDialog : Gtk.Application{
		private Gtk.ApplicationWindow window;
		private Gtk.HeaderBar headerBar;
		private Gtk.Button cancel_button;
		private Gtk.Button send_button;
		private Gtk.Button reload_button;
		private Gtk.TreeView tv;
		private Gtk.StyleContext style_context;
		private SList<Device> device_list;
		private SList<File> files;
		private DBusConnection conn;

		public DeviceDialog (SList<File> files, DBusConnection conn){
			Object (application_id: "com.bajoja.kdeconnectindicator",
				flags: ApplicationFlags.FLAGS_NONE);

			this.files = files.copy ();
			this.conn = conn;
		}

		protected override void activate () {
			this.window = new Gtk.ApplicationWindow (this);
			this.window.set_icon_name ("kdeconnect");
			window.set_default_size (500, 350);
			window.border_width = 10;

			this.headerBar = new Gtk.HeaderBar ();
			this.headerBar.set_title ("KDEConnect-Send");
			this.headerBar.set_subtitle (_("Send To"));

			this.cancel_button = new Gtk.Button.with_label(_("Cancel"));
			this.headerBar.pack_start (cancel_button);

			this.send_button = new Gtk.Button.with_label (_("Send"));
			this.style_context = send_button.get_style_context ();
			this.style_context.add_class ("suggested-action");
			this.send_button.sensitive = false;
			this.headerBar.pack_end (send_button);

			this.reload_button = new Gtk.Button.from_icon_name ("reload", 
									    Gtk.IconSize.LARGE_TOOLBAR);
			this.headerBar.pack_end (reload_button);

			window.set_titlebar (headerBar);

			Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			content.pack_start (new Gtk.Label (_("There's %u file(s) to be send")
							   .printf(this.files.length ())),
							   false, true, 10);

			this.tv = new Gtk.TreeView ();
			this.tv.headers_visible = false;
           		Gtk.CellRendererText cell = new Gtk.CellRendererText ();
                        this.tv.insert_column_with_attributes (-1,"Device",cell,"text",0);
                        content.pack_start (tv);

			connect_signals ();

                        reload_device_list ();

                        window.add (content);

			window.show_all ();

		}

		private void connect_signals (){
			this.tv.cursor_changed.connect (() => {
				this.send_button.sensitive = (get_selected()>=0);
			});

			this.tv.row_activated.connect ((path, column) => {
                		tv.set_cursor (path, null, false);
               		 	send_items ();
           		 });

			this.cancel_button.clicked.connect (() => {
				this.window.close ();
			});

			this.send_button.clicked.connect (() => {
				send_items ();
			});

			this.reload_button.clicked.connect (() => {
				reload_device_list ();
			});
		}

		private int get_selected (){
			Gtk.TreePath path;
            		Gtk.TreeViewColumn column;
            		this.tv.get_cursor (out path, out column);
            		if (path == null)
                		return -1;
            		return int.parse (path.to_string ());
		}

		private void set_device_list (Gtk.ListStore device_list) {
            		this.tv.set_model (device_list);

            		// select first item
            		Gtk.TreePath path = new Gtk.TreePath.from_indices (0, -1);
            		tv.set_cursor (path, null, false);
		}

		private void reload_device_list (){
			string[] id_list = {};
        		try {
            		     var return_variant = conn.call_sync (
                    			"org.kde.kdeconnect",
                    			"/modules/kdeconnect",
                    			"org.kde.kdeconnect.daemon",
                    			"devices",
                    			new Variant ("(b)", true),
                    			null,
                    			DBusCallFlags.NONE,
                    			-1,
                    			null
                    			);
            			Variant i = return_variant.get_child_value (0);
            			id_list = i.dup_strv ();
        		} catch (Error e) {
            			message (e.message);
        		}

        		Gtk.ListStore list_store = new Gtk.ListStore (1,typeof(string));

        		this.device_list = new SList<Device> ();
        		foreach (string id in id_list) {
            			var d = new Device ("/modules/kdeconnect/devices/"+id);
           			if (d.is_reachable && d.is_trusted) {
                			device_list.append (d);
                			Gtk.TreeIter iter;
                			list_store.append (out iter);
                			message (d.name);
                			list_store.set (iter, 0, d.name);
            			}
        		}

        		set_device_list (list_store);
		}

		private void send_items (){
			var selected = get_selected ();
            		var selected_dev = this.device_list.nth_data (selected);
           		foreach (File file in this.files)
            			selected_dev.send_file (file.get_uri ());

            		//After send files close this window
            		this.window.close ();
		}
	}

	int main (string[] args) {
		
		//Parse arguments (File to be send)
		SList<File> files = new SList<File>();

		for (int i=1; i<args.length; i++){ //int i=1 descart first arg (program name)
			File file = File.new_for_commandline_arg (args[i]);

			if (file.get_path() != null && // null path means its remote file
		    	    file.query_exists ())
		    		files.append (file);
		}

		//If there's no file to be send, show a msg and close this program
		if (files.length () == 0) {
			Gtk.init(ref args);

            		message ("file(s) doesnt exist(s) or not found");

            		var msg = new Gtk.MessageDialog (null,
                  					 Gtk.DialogFlags.MODAL,
                   			                 Gtk.MessageType.WARNING,
                   			                 Gtk.ButtonsType.OK,
                     			                 "msg");

            		msg.set_markup (_("File(s) not found"));

            		msg.destroy.connect (Gtk.main_quit);
            		//msd.show ();
            		return msg.run ();
        	}
		else{

			//Ensure there is connection to dbus
        		DBusConnection conn;

			try {
            	     	     conn = Bus.get_sync (BusType.SESSION);
        		} catch (Error e) {
            		     message (e.message);
            		     return -1;
        	 	}

			//If everthing is Ok execute this
			return new DeviceDialog (files, conn).run ();
		}
	}
}
