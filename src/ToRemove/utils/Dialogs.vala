/* Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace Dialogs {
	public class ErrorMessage {
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
			new ErrorMessage(message).show ();
		}
		
		public void show(){
			if(msg != null)
				msg.run ();
		}
	}

    public class SendURL: Gtk.ApplicationWindow {
        public delegate void SendUrl(string url);              
	    private Gtk.HeaderBar headerbar;
	    private Gtk.Button cancel_button;
	    private Gtk.Button send_button;
	    private Gtk.EntryBuffer url_entry_buffer;	    
	    private Gtk.Label url_label;	    
	    private Gtk.Entry url_entry;	    	    
        private Gtk.StyleContext style_context;        
        private SendUrl send_url;

	    public SendURL(SendUrl send_url) {            
            this.send_url = send_url;
 		    this.set_default_size (600, 0);
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
    		headerbar.show_close_button = false;
        	headerbar.title = _("Send URL");
        	this.set_titlebar(headerbar);

		    this.cancel_button = new Gtk.Button.with_label(_("Cancel"));		
		    headerbar.pack_start (cancel_button);

        	this.send_button = new Gtk.Button.with_label (_("Send"));
        	this.send_button.sensitive = false;
		    this.style_context = send_button.get_style_context ();
		    this.style_context.add_class ("suggested-action");
        	headerbar.pack_end (send_button);
		    
        	this.url_label = new Gtk.Label.with_mnemonic (_("URL: "));
        	this.url_entry_buffer = new Gtk.EntryBuffer ();
        	this.url_entry = new Gtk.Entry.with_buffer (url_entry_buffer);

        	var hbox_phone_number = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	hbox_phone_number.pack_start (url_label, false, false, 0);
        	hbox_phone_number.pack_end (url_entry, true, true, 0);	

        	Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        	box.pack_start (hbox_phone_number, false, false, 0);
        	box.spacing = 10;

        	this.add (box);
        	this.show_all ();
    	}

    	private void connect_signals (){
		    this.cancel_button.clicked.connect (on_cancel_button);
            this.send_button.clicked.connect (on_send_button);
            this.url_entry_buffer.inserted_text.connect (on_text_change);
            this.url_entry_buffer.deleted_text.connect (on_text_change);
    	}

    	private void on_cancel_button (){
    		this.destroy ();
    	}

    	private void on_send_button (){
    		this.send_url (this.url_entry_buffer.text);
		    this.destroy ();
        }	
        
        private void on_text_change(){
            if(this.url_entry_buffer.text == "" || this.url_entry_buffer.text == null){
                this.send_button.sensitive = false;
            }
            else{
                this.send_button.sensitive = true;
            }
        }
	}
}