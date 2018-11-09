/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {    
    public class ErrorMessage : Object {
		Gtk.MessageDialog msg = null;
		
		public ErrorMessage(string message) {
			msg = new Gtk.MessageDialog (null,
										 Gtk.DialogFlags.MODAL,
			                             Gtk.MessageType.WARNING,
			                             Gtk.ButtonsType.OK,
			                             "msg");
	
			msg.set_markup (_(message));
	
			msg.destroy.connect (Gtk.main_quit);
		}

		public ErrorMessage.show_message(string message) {
		    debug (@"Building a ErrorMessage, $message");
			new ErrorMessage(message).show ();
		}
		
		public void show(){
			if(msg != null)
				msg.run ();
		}
	}

	public class SendGenericText: Gtk.ApplicationWindow {
	    private Gtk.HeaderBar headerbar;
	    private Gtk.Button cancel_button;
	    private Gtk.Button send_button;
	    private Gtk.EntryBuffer text_entry_buffer;
	    private Gtk.Label text_label;
	    private Gtk.Entry text_entry;
        private Gtk.StyleContext style_context;        		
		public signal void send_callback (string text);

	    public SendGenericText(string title, string description) {
 		    this.set_default_size (600, 0);
		    this.window_position = Gtk.WindowPosition.CENTER;
		    this.set_border_width (10);
		    this.set_resizable (true);
		    this.expand = true;

		    create_widget (title, description);
		    connect_signals ();
    	}

    	private void create_widget(string title, string description){
    		//HeaderBar
    		this.headerbar = new Gtk.HeaderBar ();
			headerbar.show_close_button = false;
			headerbar.title = title;
        	//headerbar.title = _("Send URL");
        	this.set_titlebar(headerbar);

		    this.cancel_button = new Gtk.Button.with_label(_("Cancel"));		
		    headerbar.pack_start (cancel_button);

        	this.send_button = new Gtk.Button.with_label (_("Send"));
        	this.send_button.sensitive = false;
		    this.style_context = send_button.get_style_context ();
		    this.style_context.add_class ("suggested-action");
        	headerbar.pack_end (send_button);

			this.text_label = new Gtk.Label.with_mnemonic (description);
        	//this.text_label = new Gtk.Label.with_mnemonic (_("URL: "));
        	this.text_entry_buffer = new Gtk.EntryBuffer ();
        	this.text_entry = new Gtk.Entry.with_buffer (text_entry_buffer);

        	var hbox_phone_number = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	hbox_phone_number.pack_start (text_label, false, false, 0);
        	hbox_phone_number.pack_end (text_entry, true, true, 0);

        	Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        	box.pack_start (hbox_phone_number, false, false, 0);
        	box.spacing = 10;

        	this.add (box);
        	this.show_all ();
    	}

    	private void connect_signals (){
		    this.cancel_button.clicked.connect (on_cancel_button);
            this.send_button.clicked.connect (on_send_button);
            this.text_entry_buffer.inserted_text.connect (on_text_change);
            this.text_entry_buffer.deleted_text.connect (on_text_change);
    	}

    	private void on_cancel_button (){
    		this.destroy ();
    	}

    	private void on_send_button (){
			debug ("Sending a generic Text");
			send_callback (this.text_entry_buffer.text);
		    this.destroy ();
        }
        
        private void on_text_change(){
            debug ("Generic text change");
			if(this.text_entry_buffer.text == "" ||
			   this.text_entry_buffer.text == null){
                this.send_button.sensitive = false;
            }
            else{
                this.send_button.sensitive = true;
            }
        }
	}

	public class RemoteKeyboardWindow: Gtk.ApplicationWindow {
		public signal void send_callback (string key, int specialKey, bool shift, bool ctrl, bool alt);
        private Gtk.HeaderBar headerbar;
        private Gtk.EntryBuffer entry_buffer;
        private Gtk.Label label;
        private Gtk.Entry entry;

 	    public RemoteKeyboardWindow() {
 		    this.set_default_size (400, 0);
		    this.window_position = Gtk.WindowPosition.CENTER;
		    this.set_border_width (10);
		    this.set_resizable (true);
			this.expand = true;

 		    create_widget ();
		    connect_signals ();
		}

     	private void create_widget(){
    		//HeaderBar
    		this.headerbar = new Gtk.HeaderBar ();
    		headerbar.show_close_button = true;
        	headerbar.title = _("Remote Keyboard");
        	this.set_titlebar(headerbar);

        	this.label = new Gtk.Label.with_mnemonic (_("Type here: "));
        	this.entry_buffer = new Gtk.EntryBuffer ();
        	this.entry = new Gtk.Entry.with_buffer (entry_buffer);
         	var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	hbox.pack_start (label, false, false, 0);
        	hbox.pack_end (entry, true, true, 0);
         	Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        	box.pack_start (hbox, false, false, 0);
        	box.spacing = 10;
         	this.add (box);
        	this.show_all ();
		}

     	private void connect_signals () {
            this.entry_buffer.inserted_text.connect ((position, chars, n_chars) => {
                if (chars!= "" || chars !=null){
    		    	this.send_callback(chars, 0, false, false, false);
                }
			});

            this.entry.key_press_event.connect ((e) => {
                uint8 keyval = (uint8) e.keyval;
                int specialKey = getSpecialKey(keyval);
                if (specialKey > 0 && specialKey <= 32) {
                    this.send_callback("", specialKey, false, false, false);
                }
                return !isKeypressPropagated(keyval); //false to propagate the event further
			});


		 }

		private int getSpecialKey(uint keyval) {
			switch (keyval) {
			  	case 8: return 1; // backspace
			  	case 9: return 2; // tab
			  	case 81: return 4; // left
			  	case 82: return 5; // up
			  	case 83: return 6; // right
			  	case 84: return 7; // down
			  	case 80: return 10; // home
			  	case 87: return 11; // end
			  	case 13: return 12; // return
			  	case 255: return 13; // delete
			}
			return 0; // invalid
		}

		private bool isKeypressPropagated(uint keyval) {
			switch (keyval) {
			  case 9: return false; // tab
			}
			return true;
		}
    }
}
