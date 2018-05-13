/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */
namespace Utils {
    public class Pair<F,S> : GLib.Object {
        private F _first;
        private S _secound;

        public Pair(F first, S secound) {
            this._first = first;
            this._secound = secound;
        }

        public void set_first(F first) {
            this._first = first;
        }

        public S get_first() {
            return this._first;
        }

        public void set_secound(F secound) {
            this._secound = secound;
        }

        public S get_secound() {
            return this._secound;
        }
}
}