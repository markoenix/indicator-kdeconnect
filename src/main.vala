/* Copyright 2014 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")] extern const string LOCALEDIR;

namespace KDEConnectIndicator {
    public class Application : Gtk.Application {
        private KDEConnectManager manager;
        private FirstTimeWizard ftw;

        public Application () {
            Object (application_id: "com.bajoja.indicator-kdeconnect",
                    flags: ApplicationFlags.FLAGS_NONE);

        }

        protected override void startup () {
            base.startup ();

            manager = new KDEConnectManager ();
            var startup = new StartupManager ();

            if (ftw == null && manager.get_devices_number () == 0 && !startup.is_installed ()) {
                ftw = new FirstTimeWizard (manager);
                startup.install ();
            }

            new MainLoop ().run ();
        }

        protected override void activate () {
            if (manager.get_devices_number () == 0)
                ftw = new FirstTimeWizard (manager);
            else
                message ("user already know how to pair, dont show FirstTimeWizard");
        }
    }
    
    int main (string[] args) {
        GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
  	GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
  	GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  	GLib.Intl.textdomain (GETTEXT_PACKAGE);

        Application app = new Application ();
        return app.run (args);
    }
}
