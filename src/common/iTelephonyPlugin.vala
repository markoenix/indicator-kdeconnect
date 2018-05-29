/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface ITelephony : Object {
        protected void send_sms (ref DBusConnection conn, 
                                 string path,
                                 string phone_number,
                                 string message) {                                        
            try {
                conn.call_sync ("org.kde.kdeconnect",
                                path+"/telephony",
                                "org.kde.kdeconnect.device.telephony",
                                "sendSms",
                                new Variant ("(ss)",
                                             phone_number,
                                             message),
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