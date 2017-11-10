/* Copyright 2017 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
using Gtk;

[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace KDEConnectIndicator {

	class SettingsDialog : Gtk.Application {
		private GLib.Settings settings;
		private ApplicationWindow window;
		private HeaderBar headerBar;
		private Button cancel_button;
		private Button ok_button;
		private StyleContext style_context;
		private Stack stack;
		private StackSwitcher stack_switcher;


		public SettingsDialog () {
			Object (application_id: "com.bajoja.indicator-kdeconnect-settings",
				flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {
			this.settings = new GLib.Settings("com.bajoja.indicator-kdeconnect");
			create_window ();
		}

		private void create_window () {
			this.window = new Gtk.ApplicationWindow (this);
			this.window.set_icon_name ("kdeconnect");
			this.window.set_default_size (200, 150);
			this.window.border_width = 10;

			this.headerBar = new Gtk.HeaderBar ();

			this.cancel_button = new Gtk.Button.with_label (_("Cancel"));
			this.headerBar.pack_start (cancel_button);

			this.ok_button = new Gtk.Button.with_label (_("Apply"));
			this.style_context = ok_button.get_style_context ();
			this.style_context.add_class ("suggested-action");
			this.headerBar.pack_end (ok_button);

			this.stack = new Stack ();

			this.stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

			this.stack.add_titled(create_visibility_setts (), "visibility", _("Visibility"));

			this.stack.add_titled (create_sms_setts (), "sms", _("SMS"));

        		this.stack_switcher = new StackSwitcher ();
        		this.stack_switcher.halign = Gtk.Align.CENTER;
			this.stack_switcher.set_stack (stack);

			Box title = new Box (Gtk.Orientation.VERTICAL, 0);
        		title.pack_start (stack_switcher, false, false, 0);

        		create_signals ();

        		this.headerBar.set_custom_title (title);

                        this.window.set_titlebar (headerBar);

                        this.window.add (stack);

			this.window.show_all ();
		}

		private void create_signals () {

			this.cancel_button.clicked.connect (() => {
				this.window.close ();
			});

			this.ok_button.clicked.connect (() => {
				this.settings.apply ();
				restart();
				this.window.close ();
			});


		}

		private void restart () {
			string std_out;

			message("Getting PID");

            		try{
			    Process.spawn_sync (null,
			     			new string[]{"pidof",
			     			             "indicator-kdeconnect"},
			    			null,
			    			SpawnFlags.SEARCH_PATH,
			    			null,
			                        out std_out,
			    			null,
			    			null);
	    		} catch (Error e){
			    message (e.message);
             		}


             		if (std_out != ""){
             			message("Kill PID");

             			int pid = int.parse(std_out);

             			try{
			    	    Process.spawn_sync (null,
			     		    	        new string[]{"kill",
			     		    	                     pid.to_string()},
			    			        null,
			    			        SpawnFlags.SEARCH_PATH,
			    			        null,
			                        	out std_out,
			    				null,
			    				null);
	    			} catch (Error e){
			    	    message (e.message);
             			}


				message("Restart process");
             			try{
		    		    Process.spawn_async (null,
		    					 new string[]{"indicator-kdeconnect"},
				        		 null,
				        		 SpawnFlags.SEARCH_PATH,
					                 null,
				                         null);
	    			} catch (Error e) {
		    		    message (e.message);
            			}
             		}
		}

		private Box create_visibility_setts () {
			Label label1 = new Label (_("Show only paired devices: "));

			Switch switch1 = new Switch ();
			switch1.set_active (settings.get_boolean ("visibilitiy"));

			switch1.notify["active"].connect (() => {
				settings.set_boolean ("visibilitiy", switch1.active);
			});

			Box hbox1 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox1.pack_start (label1, true, true, 0);
			hbox1.pack_start (switch1, true, true, 0);

			ListBoxRow boxrow1 = new ListBoxRow ();

			boxrow1.add (hbox1);

			//----------------------------------------------------//

			Label label2 = new Label (_("Show device directories: "));

			Switch switch2 = new Switch ();
			switch2.set_active (settings.get_boolean ("list-device-dir"));

			switch2.notify["active"].connect (() => {
				settings.set_boolean ("list-device-dir", switch2.active);
			});

			Box hbox2 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox2.pack_start (label2, true, true, 0);
			hbox2.pack_start (switch2, true, true, 0);

			ListBoxRow boxrow2 = new ListBoxRow ();

			boxrow2.add (hbox2);

			//----------------------------------------------------//

			ListBox list_box = new ListBox ();
			list_box.set_selection_mode (Gtk.SelectionMode.NONE);


			list_box.add (boxrow1);
			list_box.add (boxrow2);

			Box vbox = new Box (Gtk.Orientation.HORIZONTAL, 0);
        		vbox.pack_start (list_box, true, true, 0);

        		return vbox;
		}

		private Box create_sms_setts () {
			Label label1 = new Label (_("Delete Google Contacts: "));

			Gtk.Button button1 = new Gtk.Button.from_icon_name ("user-trash");

			button1.sensitive = false;

			string _contacts = GLib.Environment. get_user_data_dir()+
				            "/indicator-kdeconnect/sms/contacts.json";

			string _token = GLib.Environment. get_user_data_dir()+
			                 "/indicator-kdeconnect/sms/token.json";

			File contacts = File.new_for_path (_contacts);
			File token = File.new_for_path (_token);

			if (contacts.query_exists () || token.query_exists ())
				button1.sensitive = true;

			button1.clicked.connect (() => {
				bool tmp = false;

				if (contacts.query_exists ())
					try{
					     contacts.delete ();
					     tmp = true;
					} catch (Error e){
					     message (e.message);
					     tmp = false;
					}

				if (token.query_exists ())
					try{
					     token.delete ();
					     tmp = true;
					} catch (Error e){
					     message (e.message);
					     tmp = false;
					}

				if (tmp)
					button1.sensitive = false;
			});

			ListBox list_box = new ListBox ();
			list_box.set_selection_mode (Gtk.SelectionMode.NONE);

			Box hbox1 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			ListBoxRow boxrow1 = new ListBoxRow ();

			boxrow1.add (hbox1);

			hbox1.pack_start (label1, true, true, 0);
			hbox1.pack_start (button1, true, true, 0);

			list_box.add (boxrow1);

			Box vbox = new Box (Gtk.Orientation.HORIZONTAL, 0);
        		vbox.pack_start (list_box, true, true, 0);

        		return vbox;
        	}
	}

	int main (string[] args) {
		return new SettingsDialog ().run (args);
	}
}
