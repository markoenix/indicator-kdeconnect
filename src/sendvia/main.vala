/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
using Gtk;
using Gee;
using IndicatorKDEConnect;

namespace SendViaKDEConnect{
	private SList<File> files;

	class SendDialog : Gtk.Application, IDaemon {
		private static bool version;
        private static bool kdeconnect_api_version;
        private static bool debug = false;
        private const OptionEntry[] options = {
            { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
            { "api-version", 0, 0, OptionArg.NONE, ref kdeconnect_api_version, "Display KDEConnect API version number", null },
            { "debug", 'd', 0, OptionArg.NONE, ref debug, "Show debug information", null},
            { null }
        };
		private ApplicationWindow window;
		private HeaderBar headerBar;
		private Button cancel_button;
		private Button send_button;
		private Button reload_button;
		private Button multiselect_button;
		private StyleContext style_context;
		private TreeView tv;
		private Gtk.ListStore list_store;
		private DBusConnection conn;
		private TreeSelection ts;
		private HashSet<DeviceManager> device_list;		
		private CellRendererToggle toggle;
		private TreeViewColumn column1;
		private TreeViewColumn column2;
		private CellRendererText text;
		private bool multiselection = false;
		private TreeIter iter;
		private HashSet<uint> subs_identifier;
		private enum Columns {TEXT, TOGGLE,	N_COLUMNS}

		public SendDialog () {
			Object (application_id: "com.indicator-kdeconnect.sendvia",
				    flags: ApplicationFlags.HANDLES_OPEN);

			try {
				conn = Bus.get_sync (BusType.SESSION);
				device_list = new HashSet<DeviceManager> ();
                subs_identifier = new HashSet<uint> ();
                
                uint id;                            
                id = subscribe_device_added (ref conn);
				subs_identifier.add (id);
				
				id = subscribe_device_removed (ref conn);
				subs_identifier.add (id);
				
				id = subscribe_device_visibility_changed (ref conn);
				subs_identifier.add (id);							
			}
			catch (Error e) {
				message (e.message);
			}						
		}

		~SendDialog() {			
			subs_identifier.@foreach ( (item) =>  {
                conn.signal_unsubscribe (item); 
			});

			iter.free();
		}

		protected override void activate () {
			if (files.length () == 0) {
				message ("file(s) doesnt exist(s) or not found");
				
				new ErrorMessage.show_message (_("File(s) not found"));
			}
			else{
				create_window ();
				create_signals ();
				reload_device_list ();
			}
		}

		protected override void open (File[] _files, string hint) {
			files = new SList<File>();

			foreach (File file in _files) {
				message ("%s".printf(file.get_uri ()));
				if (file.get_path() != null && // null path means its remote file
		    	    file.query_exists ())		
					files.append (file);
			}

			if (files.length () > 0)
				activate ();
		}

		private void create_window () {
			this.window = new Gtk.ApplicationWindow (this);
			this.window.set_icon_name ("kdeconnect");
			this.window.set_default_size (360, 200);
			this.window.border_width = 10;

			this.headerBar = new Gtk.HeaderBar ();
			this.headerBar.set_title ("SendVia");
			this.headerBar.set_subtitle ("KDEConnect");

			this.cancel_button = new Gtk.Button.with_label (_("Cancel"));
			this.headerBar.pack_start (cancel_button);

			this.send_button = new Gtk.Button.with_label (_("Send"));
			this.style_context = send_button.get_style_context ();
			this.style_context.add_class ("suggested-action");
			this.send_button.sensitive = false;
			this.headerBar.pack_end (send_button);

			//TODO: Add tooltip to the this buttons
			this.reload_button = new Gtk.Button.from_icon_name ("reload",
										Gtk.IconSize.LARGE_TOOLBAR);

			this.reload_button.set_tooltip_text (_("Reload the list of devices"));										
			this.headerBar.pack_end (reload_button);

			this.multiselect_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle",
																     Gtk.IconSize.LARGE_TOOLBAR);

			this.multiselect_button.set_tooltip_text (_("Enable alternative multi device selection"));										
			this.headerBar.pack_start (multiselect_button);										

			Box content = new Box (Gtk.Orientation.VERTICAL, 0);

			content.pack_start (new Label (_("There's %u file(s) to be send")
											 .printf (files.length ())), 
								false, 
								true, 
								10);

			this.list_store = new Gtk.ListStore (Columns.N_COLUMNS, 
												 typeof(string), 
												 typeof(bool));

			this.tv = new TreeView.with_model (this.list_store);

			this.toggle = new Gtk.CellRendererToggle ();			

			this.column1 = new Gtk.TreeViewColumn ();
			this.column1.pack_start (toggle, 
									 false);
									 
			this.column1.add_attribute (toggle, 
										"active", 
										Columns.TOGGLE);

			this.tv.append_column (column1);			
			this.column1.set_visible (this.multiselection);

			this.text = new Gtk.CellRendererText ();

			this.column2 = new Gtk.TreeViewColumn ();
			this.column2.pack_start (text, 
									 false);

			this.column2.add_attribute (text, 
										"text", 
										Columns.TEXT);

			this.tv.append_column (column2);
 
			this.tv.set_headers_visible (false);

			this.ts = this.tv.get_selection ();
			this.ts.set_mode (Gtk.SelectionMode.MULTIPLE);
			this.tv.headers_visible = false;
						
			content.pack_start (tv);

            this.window.set_titlebar (headerBar);
            this.window.add (content);

			this.window.show_all ();
		}

		private void create_signals (){
			this.toggle.toggled.connect ((toggle, path) => {
				Gtk.TreePath tree_path = new Gtk.TreePath.from_string (path);
				this.list_store.get_iter (out iter, 
										  tree_path);
										  
				this.list_store.set (iter, 
									 Columns.TOGGLE, 
									 !toggle.active);

				if (this.multiselection)
					this.send_button.sensitive = (get_selected().length > 0);					
			});

			this.tv.cursor_changed.connect (() => {
				if (!this.multiselection)
					this.send_button.sensitive = (get_selected().length > 0);						
			});

			this.tv.row_activated.connect ((path, column) => {				
				if(!this.multiselection) {
					this.tv.set_cursor (path, 
										null, 
										false);
					send_items ();
				}	            	
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

			this.multiselect_button.clicked.connect  (() => {
				this.multiselection = !this.multiselection;				
				this.column1.set_visible (this.multiselection);			
				if (this.multiselection) {
					this.send_button.sensitive = (get_selected().length > 0);	
					this.multiselect_button.set_relief (Gtk.ReliefStyle.NORMAL);					
				}
				else {
					this.multiselect_button.set_relief (Gtk.ReliefStyle.NONE);
				}								
				message ("Multisection %s",multiselection.to_string ());
			});
		}

		private Array<int> get_selected () {
            Array<int> selected_devices = new Array<int> ();

			if (!this.multiselection) {
				TreeModel tm;
            	GLib.List<TreePath> selected_paths = this.ts.get_selected_rows (out tm);

				foreach (TreePath path in selected_paths) {
					if (path != null){
						var tmp = int.parse (path.to_string ());
						selected_devices.append_val (tmp);
					}						
				}
			}
			else{
				int i = 0;
				for (bool next = list_store.get_iter_first (out iter); next; next = list_store.iter_next (ref iter)) {
					Value val1, val2;
					list_store.get_value (iter, 
										  0, 
										  out val1);

					list_store.get_value (iter, 
										  1, 
										  out val2);

					message ("Entry: %s\t%s\n", (string) val1, 
												((bool) val2).to_string());
												
					if ((bool) val2)
						selected_devices.append_val  (i);	

					i++;					
				}
			}

            return selected_devices;
		}

		private void reload_device_list() {
			this.list_store.clear ();

			string[] id_list = devices (ref conn, 
			                            true);
								
			this.device_list.clear ();											

			foreach (string id in id_list) {
			    var d = new DeviceManager ("/modules/kdeconnect/devices/"+id);
			    if (d.is_reachable && d.is_trusted) {
					device_list.add (d);
					message (d.name);
				    this.list_store.append (out iter);           			
					this.list_store.set (iter, 
										 0, 
										 d.name, 
										 1, 
										 false);
			    }
			}
	
			this.tv.set_model (this.list_store);
	
			// select first item
			Gtk.TreePath path = new Gtk.TreePath.from_indices (0, -1);
			tv.set_cursor (path, null, false);
		}

		private void add_device (string path) {
			reload_device_list ();
		}

		private void remove_device (string path) {
			reload_device_list ();
		}

		private void  distribute_visibility_changes  (string path,
													  bool visible) {
			reload_device_list ();														
		}

		private void send_items (){			
			Array<int> selected_devs = get_selected ();
			var devs = device_list.to_array ();

			for (int i = 0; i < selected_devs.length; i++) {
				devs[selected_devs.index (i)]._share_uris (files);
			}		

		    this.window.close ();
		}	

		static int main (string[] args) {
			GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
			GLib.Intl.textdomain (Config.GETTEXT_PACKAGE);
			GLib.Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.PACKAGE_LOCALEDIR);
			GLib.Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");			

			try {
				var opt_context = new OptionContext ("- sendvia-kdeconnect");
				opt_context.set_help_enabled (true);
				opt_context.add_main_entries (options, null);
				opt_context.parse (ref args);
			} 
			catch (OptionError e) {
				message ("%s\n", e.message);
				message ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
				return 1;
			}

			if (version) {
				message ("%s %s\n", Config.PACKAGE_NAME, Config.PACKAGE_VERSION);
				return 0;
			} 
			else if (kdeconnect_api_version) {
				message ("%s\n", Config.PACKAGE_API_VERSION);
				return 0;
			}

			if (debug) {
				Environment.set_variable("G_MESSAGES_DEBUG", "all", false);
				message("send-kdeconnect started in debug mode.");
			}

			return new SendDialog ().run (args);
		}
	}	
}