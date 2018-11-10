/* Copyright 2018 GConnect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {
    public class Application : Gtk.Application {
        private static bool version;
        private static bool kdeconnect_api_version;
        private static bool debug = false;
        private static bool settings_application = false;
        private static bool sendvia_application = false;
        private const OptionEntry[] options = {
            { "version", 'v', 0, OptionArg.NONE, ref version, "Display version number", null },
            { "api-version", 'a', 0, OptionArg.NONE, ref kdeconnect_api_version, "Display KDEConnect API version number", null },
            { "debug", 'd', 0, OptionArg.NONE, ref debug, "Show debug information", null},
            { "settings-application", 's', 0, OptionArg.NONE, ref settings_application, "Show Settings Application", null},
            { "sendvia-application", 'c', 0, OptionArg.NONE, ref sendvia_application, "Show SendVia Application", null},
            { null }
        };
        private KDEConnectManager kdeconnectManager;
        private FirstTimeWizard ftw;

        public Application () {
            Object (application_id: Config.IKC_APPLICATION_ID,
                    flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void startup () {
            base.startup ();            

            kdeconnectManager = new KDEConnectManager();            

            new MainLoop ().run ();
        }

        protected override void activate () {
            if (kdeconnectManager.get_number_connected_devices () == 0)
                ftw = new FirstTimeWizard (kdeconnectManager);
            else
                message ("User already know how to pair, dont show FirstTimeWizard");
        }

        static int main (string[] args) {
            GLib.Intl.setlocale (GLib.LocaleCategory.ALL, "");
			GLib.Intl.textdomain (Config.GETTEXT_PACKAGE);
			GLib.Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.PACKAGE_LOCALEDIR);
            GLib.Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
            
            Application app = new Application ();
    
            try {
                var opt_context = new OptionContext ("- indicator-kdeconnect");
                opt_context.set_help_enabled (true);
                opt_context.add_main_entries (options, null);
                opt_context.parse (ref args);
            } 
            catch (OptionError e) {
                message ("%s\n", e.message);
                message ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
                return 1;
            }
            
            if (debug) {
                Environment.set_variable("G_MESSAGES_DEBUG", "all", false);
                message("indicator-kdeconnect daemon started in debug mode.");
            }

            if (version) {
                message ("%s %s\n", Config.PACKAGE_NAME, 
                                    Config.PACKAGE_VERSION);
                return 0;
            } 
            else if (kdeconnect_api_version) {
                message ("%s\n", Config.PACKAGE_API_VERSION);
                return 0;
            }
            else if (sendvia_application) {
                message ("Show SendVia Application");
                return new SendViaDialog ().run (args);                 
            }
            else if (settings_application){
                message ("Show Settings Application");
                return new SettingsDialog ().run (args);
            }
                            
            return app.run (args);
        }
    }
}
