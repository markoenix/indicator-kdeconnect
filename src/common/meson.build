# Lib type
indicator_kdeconnect_conf = configuration_data()
indicator_kdeconnect_conf.set_quoted('GETTEXT_PACKAGE', meson.project_name(),
                  description: 'Gettext Package')
indicator_kdeconnect_conf.set_quoted('PACKAGE_NAME', meson.project_name(),
                  description: 'Define to the name of this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_DESCRIPTION', short_description,
                  description: 'Define to a short description of this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_URL', project_web,
                  description: 'Define to the home page for this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_BUGREPORT', project_bugs,
                  description: 'Define to the address where bug reports for this package should be sent.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_API_VERSION', api_version,
                  description: 'Define to the API version of this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_VERSION', meson.project_version(),
                  description: 'Define to the version of this package.')
indicator_kdeconnect_conf.set_quoted('VERSION', meson.project_version(),
                  description: 'Version number of package')
indicator_kdeconnect_conf.set_quoted('PACKAGE_DATADIR', join_paths(get_option('prefix'), get_option('datadir')),
                  description: 'Define to datadir of this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_LOCALEDIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'),
                  description: 'Define to locale dir of this package.')
indicator_kdeconnect_conf.set_quoted('SETTINGS_PATH', '/apps/indicator-kdeconnect/',
                  description: 'Define to root path of gsettings for this package.')
indicator_kdeconnect_conf.set_quoted('SETTINGS_NAME', 'com.indicator-kdeconnect.daemon',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('IKC_APPLICATION_ID', 'com.indicator-kdeconnect.deamon',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('SV_APPLICATION_ID', 'com.indicator-kdeconnect.sendvia',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('IKCS_APPLICATION_ID', 'com.indicator-kdeconnect.settings',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('TELEPHONY_CONTACTS', '/indicator-kdeconnect/sms/contacts.json',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('TELEPHONY_SMS_TOKEN', '/indicator-kdeconnect/sms/token.json',
                  description: 'Define to root bus name for this package.')
indicator_kdeconnect_conf.set_quoted('PACKAGE_SETTINGS', meson.project_name() + ' -s',
                  description: 'Define to root bus name for this package.')


configure_file(output: 'config-header.vala',
               input: 'config-header.vala.in',
               configuration: indicator_kdeconnect_conf)

indicator_kdeconnect_constants = configuration_data()
indicator_kdeconnect_constants.set_quoted('PLUGIN_SFTP', 'kdeconnect_sftp')
indicator_kdeconnect_constants.set_quoted('PLUGIN_BATTERY', 'kdeconnect_battery')
indicator_kdeconnect_constants.set_quoted('PLUGIN_SHARE', 'kdeconnect_share')
indicator_kdeconnect_constants.set_quoted('PLUGIN_TELEPHONY', 'kdeconnect_findmyphone')
indicator_kdeconnect_constants.set_quoted('PLUGIN_FINDMYPHONE', 'kdeconnect_share')
indicator_kdeconnect_constants.set_quoted('PLUGIN_REMOTE_KEYBOARD', 'kdeconnect_remotekeyboard')
indicator_kdeconnect_constants.set_quoted('PLUGIN_PING', 'kdeconnect_ping')
indicator_kdeconnect_constants.set_quoted('SETTINGS_PAIRED_DEVICES', 'only-paired-devices')
indicator_kdeconnect_constants.set_quoted('SETTINGS_INFO_ITEM', 'info-item')
indicator_kdeconnect_constants.set_quoted('SETTINGS_BRROWSE_ITEMS', 'browse-items')
indicator_kdeconnect_constants.set_quoted('SETTINGS_SEND_URL', 'send-url')
indicator_kdeconnect_constants.set_quoted('SETTINGS_SEND_SMS', 'send-sms')
indicator_kdeconnect_constants.set_quoted('SETTINGS_FIND_PHONE', 'find-my-device')
indicator_kdeconnect_constants.set_quoted('SETTINGS_PING_ITEMS', 'ping-items')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEBUS_PROP', 'org.freedesktop.DBus.Properties')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON', 'org.kde.kdeconnect')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_DEAMON', 'org.kde.kdeconnect.daemon')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_DEVICE', 'org.kde.kdeconnect.device')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_BATTERY', 'org.kde.kdeconnect.device.battery')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_FINDPHONE', 'org.kde.kdeconnect.device.findmyphone')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_PING', 'org.kde.kdeconnect.device.ping')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_SFTP', 'org.kde.kdeconnect.device.sftp')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_SHARE', 'org.kde.kdeconnect.device.share')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_TELEPHONY', 'org.kde.kdeconnect.device.telephony')
indicator_kdeconnect_constants.set_quoted('KDECONNECT_DEAMON_KEYBOARD', 'org.kde.kdeconnect.device.remotekeyboard')
indicator_kdeconnect_constants.set_quoted('DEVICE_PATH', '/modules/kdeconnect/devices/')
indicator_kdeconnect_constants.set_quoted('MODULE_PATH', '/modules/kdeconnect')

configure_file(output: 'config-constants.vala',
               input: 'config-constants.vala.in',
               configuration: indicator_kdeconnect_constants)

module_lib_name = meson.project_name()

lib_deps = [
  modules_deps
]

module_source = [join_paths(meson.current_build_dir(), 'config-header.vala'),
		             join_paths(meson.current_build_dir(), 'config-constants.vala'),
                 'dialogs.vala',
                 'utils.vala',
                 'deviceManager.vala',
                 'settings.vala',
                 'sendVia.vala',
                 'iSettings.vala',
                 'iDaemonPlugin.vala',
                 'iDevicePlugin.vala',
                 'iBatteryPlugin.vala',
                 'iFindMyPhonePlugin.vala',
                 'iSharePlugin.vala',
                 'iTelephonyPlugin.vala',
                 'iSftpPlugin.vala',
                 'iSignals.vala',
                 'iPingPlugin.vala',
                 'iRemoteKeyboard.vala']

indicator_kdeconnect_lib = shared_library(module_lib_name,
                                          sources: module_source,                     
                                          dependencies : lib_deps,
                                          install: true)

indicator_kdeconnect_dep = declare_dependency(
                           include_directories: include_directories('.'),
                           link_with: indicator_kdeconnect_lib)

pkg = import('pkgconfig')
pkg.generate(
  libraries: indicator_kdeconnect_lib,
  filebase: package_name,
  name: meson.project_name(),
  version: meson.project_version(),
  description: short_description,
  variables: [
    'datarootdir=/usr/lib/'+join_paths(get_option('datadir')),
    'datadir=${datarootdir}',
  ],
)

meson.add_install_script(join_paths(meson_dir, 'meson_post_install.py'))