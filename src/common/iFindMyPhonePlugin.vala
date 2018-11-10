/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IFindMyPhone : Object, 
                                    ISignals {
        protected virtual void ring (ref DBusConnection conn, 
                                     string path) {                                        
            try {
                debug ("Calling Find My Phone");
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/findmyphone",
                                Constants.KDECONNECT_DEAMON_FINDPHONE,
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
