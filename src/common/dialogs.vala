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
			new ErrorMessage(message).show ();
		}
		
		public void show(){
			if(msg != null)
				msg.run ();
		}
	}
}