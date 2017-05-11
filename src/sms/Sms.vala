/* Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace KDEConnectIndicator {
    public class SMSCompose: Gtk.ApplicationWindow{
        private Device device;
	private Gtk.HeaderBar headerbar;
	private Gtk.Button cancel_button;
	private Gtk.Button send_button;
	private Gtk.EntryBuffer phone_number_buffer;
	private Gtk.TextBuffer message_body_buffer;
	private Gtk.Label phone_number_label;
	private Gtk.Label message_body_label;
	private Gtk.Entry phone_number_entry;
	private Gtk.TextView message_body_entry;
	private Gtk.Label message_length;
	private Gtk.StyleContext style_context;

	public SMSCompose(Device device){
		this.device = device;
 		this.set_default_size (350, 300);
		this.window_position = Gtk.WindowPosition.CENTER;
		this.set_border_width (10);
		this.set_resizable (false);
		this.expand = false;

		create_widget ();
		connect_signals ();
    	}

    	private void create_widget(){
    		//HeaderBar
    		this.headerbar = new Gtk.HeaderBar ();
    		headerbar.show_close_button = false;
        	headerbar.title = _("Compose SMS");
        	this.set_titlebar(headerbar);

		this.cancel_button = new Gtk.Button.with_label(_("Cancel"));
		
		headerbar.pack_start (cancel_button);

        	this.send_button = new Gtk.Button.with_label (_("Send"));
        	this.send_button.sensitive = false;
		this.style_context = send_button.get_style_context ();
		this.style_context.add_class ("suggested-action");
        	headerbar.pack_end (send_button);

		//Phone Label and Entry
        	this.phone_number_label = new Gtk.Label.with_mnemonic (_("Phone number: "));
        	this.phone_number_buffer = new Gtk.EntryBuffer ();
        	this.phone_number_entry = new Gtk.Entry.with_buffer (phone_number_buffer);

        	var hbox_phone_number = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	hbox_phone_number.pack_start (phone_number_label, false, false, 0);
        	hbox_phone_number.pack_end (phone_number_entry, true, true, 0);

		//Message body
        	this.message_body_label = new Gtk.Label.with_mnemonic (_("Message body: "));
		this.message_body_buffer = new Gtk.TextBuffer (null);
		this.message_body_entry = new Gtk.TextView.with_buffer (message_body_buffer);
        	this.message_body_entry.set_right_margin (6);
        	this.message_body_entry.set_left_margin (6);
        	this.message_body_entry.set_top_margin (6);
        	this.message_body_entry.set_bottom_margin (6);
		
		var scrolled = new Gtk.ScrolledWindow (null, null);
		scrolled.add (message_body_entry);
		scrolled.set_policy (Gtk.PolicyType.AUTOMATIC,
				     Gtk.PolicyType.AUTOMATIC);

		var hbox_message_body = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		hbox_message_body.pack_start (message_body_label, false, false, 0);
		hbox_message_body.pack_end (scrolled, true, true, 0);

		message_length = new Gtk.Label.with_mnemonic ("0");
		var hmessage_length = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		hmessage_length.pack_end (message_length, false, false, 0);

        	Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        	box.pack_start (hbox_phone_number, false, false, 0);
        	box.pack_start (hbox_message_body, true, true, 0);
		box.pack_end (hmessage_length, false, false, 0);
        	box.spacing = 10;

        	this.add (box);
        	this.show_all ();
    	}

    	private void connect_signals (){
		this.cancel_button.clicked.connect (on_cancel_button);
		this.send_button.clicked.connect (on_send_button);
		this.phone_number_buffer.inserted_text.connect (on_text_change);
		this.phone_number_buffer.deleted_text.connect (on_text_change);
		this.message_body_buffer.changed.connect (on_text_change);
    	}

    	private void on_cancel_button (){
    		this.destroy ();
    	}

    	private void on_send_button (){
    		this.device.send_sms (this.phone_number_buffer.text,
				      this.message_body_buffer.text);
		this.destroy ();
    	}

    	private void on_text_change(){
		if(this.message_body_buffer.text == "" || this.message_body_buffer.text == null ||
		   this.phone_number_buffer.text == "" || this.phone_number_buffer.text == null){
			this.send_button.sensitive = false;
		}
		else{
			this.send_button.sensitive = true;
		}

		calc_message_length ();
	}

	private void calc_message_length (){
		Gtk.TextIter start, end;
		this.message_body_buffer.get_bounds (out start, out end);
		string text = this.message_body_buffer.get_text (start, end, true);
		if (text.char_count () == 0) {
			message_length.set_label ("0");
		}
		else{
			int string_length = text.char_count ();
			if(string_length < 160){
				message_length.set_label ("%d".printf(string_length));
			}
			else if(string_length > 160){
				message_length.set_label ("%d(%d)".printf(string_length, (string_length/160)+1));
			}
		}
    	}
    }
}
