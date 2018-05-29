/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IFindMyPhone : Object, ISignals {
        protected void ring (ref DBusConnection conn, 
                             string path) {                                        
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/findmyphone",
                                "org.kde.kdeconnect.device.findmyphone",
                                "ring",
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
    }
}