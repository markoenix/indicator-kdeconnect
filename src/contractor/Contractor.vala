/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
using Gtk;

[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace KDEConnectIndicator{
	private SList<File> files;

	class SendDialog : Gtk.Application {
		private ApplicationWindow window;
		private HeaderBar headerBar;
		private Button cancel_button;
		private Button send_button;
		private Button reload_button;
		private StyleContext style_context;
		private TreeView tv;
		private Gtk.ListStore list_store;
		private DBusConnection conn;
		private TreeSelection ts;
		private SList<Device> device_list;

		public SendDialog () {
			Object (application_id: "org.bajoja.kdeconnect-send",
				flags: ApplicationFlags.HANDLES_OPEN);
		}

		protected override void activate () {
			if (files.length () == 0){
				message ("file(s) doesnt exist(s) or not found");

            			var msg = new Gtk.MessageDialog (null,
                  						 Gtk.DialogFlags.MODAL,
                   			                 	 Gtk.MessageType.WARNING,
                   			                	 Gtk.ButtonsType.OK,
                     			                 	 "msg");

            			msg.set_markup (_("File(s) not found"));

            			msg.destroy.connect (Gtk.main_quit);
            			msg.run ();
			}
			else{
				create_window ();
				create_signals ();
				reload_device_list ();
			}
		}

		protected override void open (File[] _files, string hint) {
			files = new SList<File>();

			foreach (File file in _files){
				message ("%s".printf(file.get_uri ()));
				if (file.get_path() != null && // null path means its remote file
		    	    	    file.query_exists ())
		    			files.append (file);
			}

			if (files.length () == 0){

			}
			else{
				activate ();
			}
		}

		private void create_window (){
			this.window = new Gtk.ApplicationWindow (this);
			this.window.set_icon_name ("kdeconnect");
			this.window.set_default_size (500, 350);
			this.window.border_width = 10;

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

			Box content = new Box (Gtk.Orientation.VERTICAL, 0);

			content.pack_start (new Label (_("There's %u file(s) to be send")
						       .printf (files.length ())),
						       false, true, 10);

			this.tv = new TreeView ();
			this.ts = this.tv.get_selection();
			this.ts.set_mode(Gtk.SelectionMode.MULTIPLE);
			this.tv.headers_visible = false;
           		CellRendererText cell = new CellRendererText ();
                        this.tv.insert_column_with_attributes (-1,"Device",cell,"text",0);
			content.pack_start (tv);

                        this.window.set_titlebar (headerBar);
                        this.window.add (content);

			this.window.show_all ();
		}

		private void create_signals (){
			this.tv.cursor_changed.connect (() => {
				this.send_button.sensitive = (
					get_selected().length () > 0);
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

		private SList<int> get_selected (){

            		SList<int> selected_devices = new SList<int> ();

			TreeModel tm;

            		List<TreePath> selected_paths = this.ts.
            					     get_selected_rows (out tm);

			foreach (TreePath path in selected_paths){
				if(path != null)
					selected_devices.append (int.parse
							  (path.to_string ()));
			}

            		return selected_devices.copy ();
		}

		private void set_device_list (Gtk.ListStore device_list) {
            		this.tv.set_model (device_list);

            		// select first item
            		Gtk.TreePath path = new Gtk.TreePath.from_indices (0, -1);
            		tv.set_cursor (path, null, false);
		}

		private void reload_device_list (){
			try{
				conn = Bus.get_sync (BusType.SESSION);

			} catch (Error e){
				message (e.message);
				this.window.close ();
			}

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

			this.list_store = new Gtk.ListStore (1,typeof(string));
       			this.device_list = new SList<Device> ();

        		foreach (string id in id_list) {
            			var d = new Device ("/modules/kdeconnect/devices/"+id);
            			if (d.is_reachable && d.is_trusted) {
                			device_list.append (d);
                			Gtk.TreeIter iter;
                			this.list_store.append (out iter);
                			message (d.name);
                			this.list_store.set (iter, 0, d.name);
            			}
        		}

        		set_device_list (this.list_store);

		}

		private void send_items (){
			SList<int> selected_devs = get_selected ();

            		foreach (File file in files){
            			foreach (int selected in selected_devs){
            				Device selected_dev = this.device_list.
            						    nth_data (selected);

            				selected_dev.send_file (file.get_uri ());
            			}
            		}

            		this.window.close ();
		}
	}

	int main (string[] args) {
		return new SendDialog ().run (args);
	}
}

