/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface ITelephony : Object {
        protected virtual void send_sms (ref DBusConnection conn,
                                         string path,
                                         string phone_number,
                                         string message) {
            try {
                debug (@"Sending SMS: $phone_number, $message");
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/telephony",
                                Constants.KDECONNECT_DEAMON_TELEPHONY,
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
