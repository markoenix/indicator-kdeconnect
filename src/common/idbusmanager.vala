/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace IndicatorKDEConnect {    
    public interface IDBusManager : Object {
		public virtual uint signal_subscribe (ref DBusConnection conn,
											  string sender,
											  string interface,
											  string method,
											  string object_path,
											  DBusSignalCallback callback) {
			uint return_value = -1;				
			return_value = conn.signal_subscribe (sender,
												  interface,
												  method,
												  object_path,
												  null,
												  DBusSignalFlags.NONE,
												  callback);																					
			return return_value;
		}

		public virtual void signal_unsubscribe (ref DBusConnection conn,
												uint signal_id) {
			conn.signal_unsubscribe (signal_id);
		}

		public virtual Variant call_sync (ref DBusConnection conn,
									      string sender,
									      string interface,
									      string method,
									      string object_path,
									      Variant args) {
			Variant variant = null;
			try {
				variant = conn.call_sync (sender,
								   		  object_path,
							       		  interface,
								   		  method,
								   		  args,
								   		  null,
								   		  DBusCallFlags.NONE,
								   		  -1,
								   		  null);										   
			}
			catch (Error e) {
				debug (e.message);
			}
			return variant;
		}

		public virtual DBusProxy sync_proxy (ref DBusConnection conn,
									         string sender,
									         string interface,									   
									         string object_path) {
			DBusProxy dbus_proxy = null;
			try {
				dbus_proxy = new DBusProxy.sync (conn,
												 DBusProxyFlags.NONE,
												 null,
												 sender,
			 									 object_path,
			 									 interface,
			 									 null);			
			}
			catch (Error e) {
				debug (e.message);
			}				
			return dbus_proxy;
		}
	}
}