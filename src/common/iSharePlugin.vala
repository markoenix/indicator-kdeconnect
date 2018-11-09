/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IShare : Object, 
                              ISignals {
        protected virtual void share (ref DBusConnection conn, 
                                      string path,
                                      string url) {                                        
            try {
                debug ("Sharing a file");
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/share",
                                Constants.KDECONNECT_DEAMON_SHARE,
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
