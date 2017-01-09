/* Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace KDEConnectIndicator {
    public class SMS{
        public string phone_number {get; set;}
        public string message_body {get; set;}

    	public SMS(string phone_number, string message_body){
    		this.phone_number = phone_number;
    		this.message_body = message_body;
    	}

    	public bool is_empty(){
    		return phone_number == null || phone_number == ""  &&
    		       message_body == null || message_body == "";
    	}
    }

    public class SMSDialog: Gtk.Dialog{
    	private Gtk.Entry phone_number_entry;
    	private Gtk.TextView message_body_entry;
    	private Gtk.EntryBuffer buffer_phone_number;
    	private Gtk.TextBuffer buffer_message_body;
    	private Gtk.Widget send_button;

	public SMSDialog(){
		this.title = _("Compose SMS");
		this.border_width = 10;
		set_resizable(false);
            	set_default_size (300, 350);
            	create_widgets();
            	connect_signals();
	}

	private void create_widgets(){
		//Phone Number Label and entry
	 	var phone_number_label = new Gtk.Label.with_mnemonic (_("Phone number: "));
	 	buffer_phone_number = new Gtk.EntryBuffer (null);
		phone_number_entry = new Gtk.Entry.with_buffer (buffer_phone_number);

		phone_number_label.mnemonic_widget = phone_number_entry;

		var hbox_phone_number = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        	hbox_phone_number.pack_start (phone_number_label, false, true, 0);
        	hbox_phone_number.pack_start (phone_number_entry, true, true, 0);

        	//Message Body Label
		var message_body_label = new Gtk.Label.with_mnemonic (_("Message body: "));

		buffer_message_body = new Gtk.TextBuffer (null);
		message_body_entry = new Gtk.TextView.with_buffer (buffer_message_body);
                message_body_entry.set_wrap_mode (Gtk.WrapMode.WORD);

		message_body_label.mnemonic_widget = message_body_entry;

		var scrolled = new Gtk.ScrolledWindow (null, null);
		scrolled.add (message_body_entry);
		scrolled.set_policy (Gtk.PolicyType.AUTOMATIC,
		        	     Gtk.PolicyType.AUTOMATIC);

        	var hbox_message_body = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        	hbox_message_body.pack_start (message_body_label, false, true, 0);

		//Content Package
		var content = get_content_area () as Gtk.Box;
        	content.pack_start (hbox_phone_number, false, true, 0);
        	content.pack_start (hbox_message_body, false, true, 0);
        	content.pack_start (scrolled, true, true, 0);
        	content.spacing = 5;

        	add_button ((_("Cancel")), Gtk.ResponseType.CANCEL);
        	send_button = add_button ((_("Send")), Gtk.ResponseType.OK);
        	this.send_button.sensitive = false;

		this.show_all();
	}

	private void connect_signals () {
		this.response.connect (on_response);
		this.buffer_phone_number.inserted_text.connect (on_text_change);
		this.buffer_phone_number.deleted_text.connect (on_text_change);
		this.buffer_message_body.changed.connect (on_text_change);
	}

	private void on_text_change(){
		if(this.buffer_message_body.text == "" || this.buffer_message_body == null ||
		   this.buffer_phone_number.text == "" || this.buffer_phone_number == null){
			this.send_button.sensitive = false;
		}
		else{
			this.send_button.sensitive = true;
		}
	}

	private void on_response (Gtk.Dialog source, int response_id) {
           	if (response_id==Gtk.ResponseType.CANCEL)
           		destroy ();
    	}

    	public SMS get_sms(){
		SMS sms = new SMS(this.buffer_phone_number.text,
		                  this.buffer_message_body.text);
		return sms;
    	}
    }
}
