/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IShare : Object, ISignals {
        protected void share (ref DBusConnection conn, 
                              string path,
                              string url) {                                        
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/share",
                                "org.kde.kdeconnect.device.share",
                                "shareUrl",
                                new Variant ("(s)",
                                             url),
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
