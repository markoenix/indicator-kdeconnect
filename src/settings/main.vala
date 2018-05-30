/* Copyright 2017 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
using Gtk;
using IndicatorKDEConnect;

[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace IndicatorKDEConnectSettings {
	class SettingsDialog : Gtk.Application {
		private static bool version;
        private static bool kdeconnect_api_version;
        private static bool debug = false;
        private const OptionEntry[] options = {
            { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
            { "api-version", 0, 0, OptionArg.NONE, ref kdeconnect_api_version, "Display KDEConnect API version number", null },
            { "debug", 'd', 0, OptionArg.NONE, ref debug, "Show debug information", null},
            { null }
        };
		private GLib.Settings settings;
		private ApplicationWindow window;
		private HeaderBar headerBar;
		private Button cancel_button;
		private Button ok_button;
		private StyleContext style_context;
		private Stack stack;
		private StackSwitcher stack_switcher;
		private bool need_restart;		
		
		public SettingsDialog () {
			Object (application_id: "com.indicator-kdeconnect.settings",
				    flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {			
			this.settings = new GLib.Settings(Config.SETTINGS_NAME);
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
				this.window.close ();
			});
		}	

		private Box create_visibility_setts () {
			Label label1 = new Label (_("Show only paired devices: "));

			Switch switch1 = new Switch ();

			switch1.set_active (settings.get_boolean ("only-paired-devices"));

			switch1.notify["active"].connect (() => {				
				settings.set_boolean ("only-paired-devices", switch1.active);								
			});
			
			Box hbox1 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox1.pack_start (label1, true, true, 0);
			hbox1.pack_start (switch1, true, true, 0);

			ListBoxRow boxrow1 = new ListBoxRow ();

			boxrow1.add (hbox1);

			//----------------------------------------------------//

			Label label2 = new Label (_("Show Menu Directories: "));

			Switch switch2 = new Switch ();

			switch2.set_active (settings.get_boolean ("browse-items"));

			switch2.notify["active"].connect (() => {
				settings.set_boolean ("browse-items", switch2.active);
			});	

			Box hbox2 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox2.pack_start (label2, true, true, 0);
			hbox2.pack_start (switch2, true, true, 0);

			ListBoxRow boxrow2 = new ListBoxRow ();

			boxrow2.add (hbox2);

			//----------------------------------------------------//

			Label label3 = new Label (_("Show Menu Send URL: "));

			Switch switch3 = new Switch ();
		
    		switch3.set_active (settings.get_boolean ("send-url"));

			switch3.notify["active"].connect (() => {
				settings.set_boolean ("send-url", switch3.active);
			});	

			Box hbox3 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox3.pack_start (label3, true, true, 0);
			hbox3.pack_start (switch3, true, true, 0);

			ListBoxRow boxrow3 = new ListBoxRow ();

			boxrow3.add (hbox3);

			//---------------------------------------------------//


			Label label4 = new Label (_("Show Menu Find Phone: "));

			Switch switch4 = new Switch ();
		
    		switch4.set_active (settings.get_boolean ("find-my-device"));

			switch4.notify["active"].connect (() => {
				settings.set_boolean ("find-my-device", switch4.active);
			});	

			Box hbox4 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox4.pack_start (label4, true, true, 0);
			hbox4.pack_start (switch4, true, true, 0);

			ListBoxRow boxrow4 = new ListBoxRow ();

			boxrow4.add (hbox4);

			//---------------------------------------------------//

			Label label5 = new Label (_("Show Menu Send SMS: "));

			Switch switch5 = new Switch ();
		
    		switch5.set_active (settings.get_boolean ("send-sms"));

			switch5.notify["active"].connect (() => {
				settings.set_boolean ("send-sms", switch5.active);
			});	

			Box hbox5 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox5.pack_start (label5, true, true, 0);
			hbox5.pack_start (switch5, true, true, 0);

			ListBoxRow boxrow5 = new ListBoxRow ();

			boxrow5.add (hbox5);

			//---------------------------------------------------//

			ListBox list_box = new ListBox ();
			list_box.set_selection_mode (Gtk.SelectionMode.NONE);

			list_box.add (boxrow1);
			list_box.add (boxrow2);
			list_box.add (boxrow3);	
			list_box.add (boxrow5);
			list_box.add (boxrow4);

			//----------------------------------------------------//

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

        static int main (string[] args) {
			try {
				var opt_context = new OptionContext ("- settings-ind-kdec");
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
				message("settings-ind-kdec started in debug mode.");
			}

            return new SettingsDialog ().run (args);
        }
	}
}