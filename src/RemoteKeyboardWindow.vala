/* Copyright 2016 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace KDEConnectIndicator {
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


    public class RemoteKeyboardWindow: Gtk.ApplicationWindow {
        public delegate void RemoteKeyboardDeleg (string key, int specialKey, bool shift, bool ctrl, bool alt);
        private Gtk.HeaderBar headerbar;
        private Gtk.EntryBuffer entry_buffer;	    
        private Gtk.Label label;	    
        private Gtk.Entry entry;	    	    
        private RemoteKeyboardDeleg remoteKeyboardDeleg;

	    public RemoteKeyboardWindow(RemoteKeyboardDeleg remoteKeyboardDeleg) {            
            this.remoteKeyboardDeleg = remoteKeyboardDeleg;
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
    		    this.remoteKeyboardDeleg(chars, 0, false, false, false);
                }
            });

            this.entry.key_press_event.connect ((e) => {
                uint8 keyval = (uint8) e.keyval;
                int specialKey = getSpecialKey(keyval);
                if (specialKey > 0 && specialKey <= 32) {
                    this.remoteKeyboardDeleg("", specialKey, false, false, false);
                }
                return !isKeypressPropagated(keyval); //false to propagate the event further
            });

    	}
    }
}
