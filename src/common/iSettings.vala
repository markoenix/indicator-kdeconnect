/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace IndicatorKDEConnect {
    public interface ISettings : Object {
        public virtual void subscribe_property_bool (ref Settings settings, 
                                                     string property) {
            settings.changed[property].connect (() => {
                
                setting_changed (property);
                debug (@"Settings $property, Change");
            });
        }

        public virtual bool get_property_bool (ref Settings settings, 
                                               string property) {
            debug (@"Getting Settings $property");
            return settings.get_boolean (property);                         
        }

        public signal void setting_changed (string property);
    }
}
