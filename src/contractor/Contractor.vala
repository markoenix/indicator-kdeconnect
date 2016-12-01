/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace KDEConnectIndicator {
    public class DeviceDialog : Gtk.Dialog {
        private Gtk.TreeView tv;
        private Gtk.Widget select_button;
        
        public DeviceDialog (string filename) {
            this.title = _("Send to");
            this.border_width = 10;
            set_default_size (500, 400);

            var content = get_content_area () as Gtk.Box;
            content.pack_start (new Gtk.Label (filename), false, true, 10);
            tv = new Gtk.TreeView ();
            tv.headers_visible = false;
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            tv.insert_column_with_attributes (-1,"Device",cell,"text",0);

            content.pack_start (tv);
            add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
            select_button = add_button (_("Send"), Gtk.ResponseType.OK);

            show_all ();
            this.response.connect (on_response);

            tv.cursor_changed.connect (()=>{
                this.select_button.sensitive = (get_selected()>=0);
            });
            tv.row_activated.connect ((path, column) => {
                tv.set_cursor (path, null, false);
                this.response (Gtk.ResponseType.OK);
            });
        }
        
        public void set_list (Gtk.ListStore l) {
            tv.set_model (l);

            // select first item
            var path = new Gtk.TreePath.from_indices (0, -1);
            tv.set_cursor (path, null, false);
        }
        
        public int get_selected () {
            Gtk.TreePath path;
            Gtk.TreeViewColumn column;
            tv.get_cursor (out path, out column);
            if (path == null)
                return -1;
            return int.parse (path.to_string ());
        }
        
        private void on_response (Gtk.Dialog source, int id) {
            if (id==Gtk.ResponseType.CANCEL)
                destroy ();
        }
    }
    
    int main (string[] args) {
      	GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
  	GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
  	GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  	GLib.Intl.textdomain (GETTEXT_PACKAGE);

        Gtk.init (ref args);


        File f = File.new_for_commandline_arg (args[1]);

        if (f.get_path() != null // null path means its remote file
            && !f.query_exists ()) {
            message ("file doesnt exist");

            var msd = new Gtk.MessageDialog (null,
            				     Gtk.DialogFlags.MODAL,
                  			     Gtk.MessageType.WARNING,
                  			     Gtk.ButtonsType.OK,
                    			     _("File not found"));

            msd.destroy.connect (Gtk.main_quit);
            msd.show ();
            msd.run ();

            return -1;
        }

        Gtk.ListStore list_store;
        DBusConnection conn;

        try {
            conn = Bus.get_sync (BusType.SESSION);
        } catch (Error e) {
            message (e.message);
            return -1;
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

        list_store = new Gtk.ListStore (1,typeof(string));
        var device_list = new SList<Device> ();
        foreach (string id in id_list) {
            var d = new Device ("/modules/kdeconnect/devices/"+id);
            if (d.is_reachable && d.is_trusted) {
                device_list.append (d);
                Gtk.TreeIter iter;
                list_store.append (out iter);
                message (d.name);
                list_store.set (iter, 0, d.name);
            }
        }

        var d = new DeviceDialog (f.get_basename ());
        d.set_list (list_store);
        if (d.run () == Gtk.ResponseType.OK) {
            var selected = d.get_selected ();
            var selected_dev = device_list.nth_data (selected);
            selected_dev.send_file (f.get_uri ());
        }
        d.destroy.connect (Gtk.main_quit);
        d.show_all ();

        return 0;
    }
}
