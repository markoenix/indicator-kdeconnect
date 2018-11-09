/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IPing : Object,
                       ISignals {
        protected virtual void send_ping (ref DBusConnection conn,
                                          string path,
                                          string? message = null) {
            try {
                debug ("Sending a Ping");

                Variant pingMessage = null;
                if(message != null)
                    pingMessage = new Variant ("(s)",
                                               message);

                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/ping",
                                Constants.KDECONNECT_DEAMON_PING,
                                "sendPing",
                                pingMessage,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);                
            } 
            catch (Error e) {
                debug (e.message);
            }          
        }
    }
}
