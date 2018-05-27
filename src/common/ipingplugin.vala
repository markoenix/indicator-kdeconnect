/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IPing : Object, ISignals {
        protected void send_ping (ref DBusConnection conn, 
                                  string path) {                                        
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path,
                                "org.kde.kdeconnect.device.ping",
                                "sendPing",
                                null,
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);                
            } 
            catch (Error e) {
                debug (e.message);
            }          
        }         

        protected void send_ping (ref DBusConnection conn, 
                                  string path,
                                  string message) {                            
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/ping",
                                "org.kde.kdeconnect.device.ping",
                                "send",
                                new Variant ("(s)", 
                                             message),
                                null,
                                DBusCallFlags.NONE,
                                -1,
                                null);             
            } catch (Error e) {
                debug (e.message);
            }            
        } 
    }
}