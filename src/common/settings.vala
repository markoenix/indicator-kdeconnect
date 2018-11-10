/* Copyright 2017 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
using Gtk;

namespace IndicatorKDEConnect {
	public class SettingsDialog : Gtk.Application {		
		private GLib.Settings settings;
		private ApplicationWindow window;
		private HeaderBar headerBar;
		//private Button cancel_button;
		private Button ok_button;
		private StyleContext style_context;
		private Stack stack;
		private StackSwitcher stack_switcher;

		public SettingsDialog () {
			Object (application_id: Config.IKCS_APPLICATION_ID,
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

			//this.cancel_button = new Gtk.Button.with_label (_("Cancel"));
			//this.headerBar.pack_start (cancel_button);

			this.ok_button = new Gtk.Button.with_label (_("Apply"));
			this.style_context = ok_button.get_style_context ();
			this.style_context.add_class ("suggested-action");
			this.headerBar.pack_end (ok_button);

			this.stack = new Stack ();

			this.stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

			this.stack.add_titled(create_visibility_setts (), 
								  "visibility", 
								  _("Visibility"));

			this.stack.add_titled (create_sms_setts (), 
								   "sms", 
								   _("SMS"));

        	this.stack_switcher = new StackSwitcher ();
        	this.stack_switcher.halign = Gtk.Align.CENTER;
			this.stack_switcher.set_stack (stack);

			Box title = new Box (Gtk.Orientation.VERTICAL, 
								 0);

			title.pack_start (stack_switcher,
							  false, 
							  false, 
							  0);

        	create_signals ();

        	this.headerBar.set_custom_title (title);
			this.window.set_titlebar (headerBar);
			this.window.add (stack);

			this.window.show_all ();
		}

		private void create_signals () {
			//  this.cancel_button.clicked.connect (() => {				
			//  	this.window.close ();
			//  });

			this.ok_button.clicked.connect (() => {
				this.settings.apply ();
				this.window.close ();
			});
		}	

		private Box create_visibility_setts () {
			var checkBtn1 = new Gtk.CheckButton.with_label (_("Show only paired devices"));

			checkBtn1.set_active (settings.get_boolean (Constants.SETTINGS_PAIRED_DEVICES));

			checkBtn1.notify["active"].connect (() => { 
				message ("Setting only-paired-devices %s", checkBtn1.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_PAIRED_DEVICES,
									  checkBtn1.active);
			});
			
			Box hbox1 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox1.pack_start (checkBtn1,
							  true,
							  true, 
							  0);

			ListBoxRow boxrow1 = new ListBoxRow ();

			boxrow1.add (hbox1);

			//----------------------------------------------------//
			var checkBtn2 = new Gtk.CheckButton.with_label (_("Show Menu Directories"));

			checkBtn2.set_active (settings.get_boolean (Constants.SETTINGS_BRROWSE_ITEMS));

			checkBtn2.notify["active"].connect (() => {
				message ("Setting browse-items %s", checkBtn2.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_BRROWSE_ITEMS, 
									  checkBtn2.active);
			});

			Box hbox2 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox2.pack_start (checkBtn2,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow2 = new ListBoxRow ();

			boxrow2.add (hbox2);

			//----------------------------------------------------//
			var checkBtn3 = new Gtk.CheckButton.with_label (_("Show Menu Send URL"));

			checkBtn3.set_active (settings.get_boolean (Constants.SETTINGS_SEND_URL));

			checkBtn3.notify["active"].connect (() => {
				message ("Setting send-url %s", checkBtn3.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_SEND_URL, 
									  checkBtn3.active);
			});

			Box hbox3 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox3.pack_start (checkBtn3,
							  true,
							  true, 
							  0);

			ListBoxRow boxrow3 = new ListBoxRow ();

			boxrow3.add (hbox3);

			//---------------------------------------------------//
			var checkBtn4 = new Gtk.CheckButton.with_label (_("Show Menu Find Phone"));

			checkBtn4.set_active (settings.get_boolean (Constants.SETTINGS_FIND_PHONE));

			checkBtn4.notify["active"].connect (() => {
				message ("Setting find-my-device %s", checkBtn4.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_FIND_PHONE, 
									  checkBtn4.active);
			});

			Box hbox4 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox4.pack_start (checkBtn4,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow4 = new ListBoxRow ();

			boxrow4.add (hbox4);

			//---------------------------------------------------//
			var checkBtn5 = new Gtk.CheckButton.with_label (_("Show Menu Send SMS"));

			checkBtn5.set_active (settings.get_boolean (Constants.SETTINGS_SEND_SMS));

			checkBtn5.notify["active"].connect (() => {
				message ("Setting send-sms %s", checkBtn5.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_SEND_SMS, 
									  checkBtn5.active);
			});

			Box hbox5 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox5.pack_start (checkBtn5,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow5 = new ListBoxRow ();

			boxrow5.add (hbox5);

			//---------------------------------------------------//
			var checkBtn6 = new Gtk.CheckButton.with_label (_("Show Menu Info"));

			checkBtn6.set_active (settings.get_boolean (Constants.SETTINGS_INFO_ITEM));

			checkBtn6.notify["active"].connect (() => {
				message ("Setting info-item %s", checkBtn6.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_INFO_ITEM,
									  checkBtn6.active);
			});

			Box hbox6 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox6.pack_start (checkBtn6,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow6 = new ListBoxRow ();

			boxrow6.add (hbox6);

			//---------------------------------------------------//

			var checkBtn7 = new Gtk.CheckButton.with_label (_("Show Ping Menus"));

			checkBtn7.set_active (settings.get_boolean (Constants.SETTINGS_PING_ITEMS));

			checkBtn7.notify["active"].connect (() => {
				message ("Setting ping-items %s", checkBtn7.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_PING_ITEMS,
									  checkBtn7.active);
			});

			Box hbox7 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox7.pack_start (checkBtn7,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow7 = new ListBoxRow ();

			boxrow7.add (hbox7);

			//---------------------------------------------------//

			var checkBtn8 = new Gtk.CheckButton.with_label (_("Show Remote Keybord"));

			checkBtn8.set_active (settings.get_boolean (Constants.SETTINGS_REMOTE_KEYBOARD));

			checkBtn8.notify["active"].connect (() => {
				message ("Setting Remote Keyboard %s", checkBtn8.active.to_string ());
				settings.set_boolean (Constants.SETTINGS_REMOTE_KEYBOARD,
									  checkBtn8.active);
			});

			Box hbox8 = new Box (Gtk.Orientation.HORIZONTAL, 50);

			hbox8.pack_start (checkBtn8,
							  true, 
							  true, 
							  0);

			ListBoxRow boxrow8 = new ListBoxRow ();

			boxrow8.add (hbox8);

			//---------------------------------------------------//

			ListBox list_box = new ListBox ();
			list_box.set_selection_mode (Gtk.SelectionMode.NONE);
			
			list_box.add (boxrow1);
			list_box.add (boxrow2);
			list_box.add (boxrow3);	
			list_box.add (boxrow4);
			list_box.add (boxrow5);
			list_box.add (boxrow6);						
			list_box.add (boxrow7);
			list_box.add (boxrow8);
			
			//----------------------------------------------------//

			Box vbox = new Box (Gtk.Orientation.HORIZONTAL,
			                    0);
			vbox.pack_start (list_box,
							 true, 
							 true, 
							 0);

        	return vbox;
		}

		private Box create_sms_setts () {
			Label label1 = new Label (_("Delete Google Contacts: "));

			Gtk.Button button1 = new Gtk.Button.from_icon_name ("user-trash");

			button1.sensitive = false;

			string _contacts = GLib.Environment. get_user_data_dir()+
				               Config.TELEPHONY_CONTACTS;

			string _token = GLib.Environment. get_user_data_dir()+
			                Config.TELEPHONY_SMS_TOKEN;

			File contacts = File.new_for_path (_contacts);
			File token = File.new_for_path (_token);

			if (contacts.query_exists () || 
			    token.query_exists ())
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

			Box hbox1 = new Box (Gtk.Orientation.HORIZONTAL, 
			                     50);

			ListBoxRow boxrow1 = new ListBoxRow ();

			boxrow1.add (hbox1);

			hbox1.pack_start (label1, 
							  true, 
							  true, 
							  0);

			hbox1.pack_start (button1, 
							  true, 
							  true, 
							  0);

			list_box.add (boxrow1);

			Box vbox = new Box (Gtk.Orientation.HORIZONTAL, 
								0);
								
			vbox.pack_start (list_box, 
							 true, 
							 true, 
							 0);

        	return vbox;
        }        
	}
}
