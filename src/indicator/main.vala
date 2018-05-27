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
        private const OptionEntry[] options = {
            { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
            { "api-version", 0, 0, OptionArg.NONE, ref kdeconnect_api_version, "Display KDEConnect API version number", null },
            { "debug", 'd', 0, OptionArg.NONE, ref debug, "Show debug information", null},
            { null }
        };
        private KDEConnectManager kdeconnectManager;

        public Application () {
            Object (application_id: "com.indicator-kdeconnect.daemon",
                    flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void startup () {
            base.startup ();            

            kdeconnectManager = new KDEConnectManager();

            new MainLoop ().run ();
        }

        protected override void activate () {

        }

        static int main (string[] args) {
            Application app = new Application ();
    
            try {
                var opt_context = new OptionContext ("- indicator-kdeconnect");
                opt_context.set_help_enabled (true);
                opt_context.add_main_entries (options, null);
                opt_context.parse (ref args);
            } catch (OptionError e) {
                message ("%s\n", e.message);
                message ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
                return 1;
            }
    
            if (version) {
                message ("%s %s\n", Config.PACKAGE_NAME, Config.PACKAGE_VERSION);
                return 0;
            } else if (kdeconnect_api_version) {
                message ("%s\n", Config.PACKAGE_API_VERSION);
                return 0;
            }
    
            if (debug) {
                Environment.set_variable("G_MESSAGES_DEBUG", "all", false);
                message("indicator-kdeconnect daemon started in debug mode.");
            }
            
            return app.run (args);
        }
    }
}
