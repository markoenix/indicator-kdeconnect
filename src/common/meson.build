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
indicator_kdeconnect_conf.set_quoted('SETTINGS_NAME', 'com.indicator-kdeconnect',
                  description: 'Define to root bus name for this package.')

configure_file(output: 'config-header.vala',
               input: 'config-header.vala.in',
               configuration: indicator_kdeconnect_conf)


module_lib_name = meson.project_name()

lib_deps = [
  modules_deps
]

module_source = [join_paths(meson.current_build_dir(), 'config-header.vala'),
                 'dialogs.vala',
                 'utils.vala',
                 'deviceManager.vala',
                 'iSettings.vala',
                 'iDaemonPlugin.vala',
                 'iDevicePlugin.vala',
                 'iBatteryPlugin.vala',
                 'iFindMyPhonePlugin.vala',
                 'iSharePlugin.vala',
                 'iTelephonyPlugin.vala',
                 'iSftpPlugin.vala',
                 'iSignals.vala'] 

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

#GSettings
install_data('indicator-kdeconnect.gschema.xml', install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas'))
meson.add_install_script(join_paths(meson_dir, 'meson_post_install.py'))