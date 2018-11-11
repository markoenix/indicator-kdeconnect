# Executable type

module_deps = [
  modules_deps,
  dependency('appindicator3-0.1'),
  indicator_kdeconnect_dep
]

module_source = ['main.vala', 
                 'kdeconnectManager.vala', 
                 'device.vala',
                 'firstTimeWizard.vala']

module_exec = executable(meson.project_name(), 
                         sources: module_source,
                         dependencies : module_deps,
                         install: true)