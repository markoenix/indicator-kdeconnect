/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface IRemoteKeyboard : Object {
        protected virtual void remote_keyboard (ref DBusConnection conn,
                                            string path,
                                            string key,
                                            int specialKey,
                                            bool shift,
                                            bool ctrl,
                                            bool alt) {
            try{
                 // TODO try async call
                debug (@"Remote Keyboard: $key, $specialKey, $shift, $ctrl, $alt");
                conn.call_sync (Constants.KDECONNECT_DEAMON,
                                path+"/remotekeyboard",
                                Constants.KDECONNECT_DEAMON_KEYBOARD,
                                "sendKeyPress",
                                new Variant ("(sibbbb)",
                                             key,
                                             specialKey,
                                             shift,
                                             ctrl,
                                             alt,
                                             false),
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
