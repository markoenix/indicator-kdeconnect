# Executable type

module_exec_name = meson.project_name()

module_deps = [
  modules_deps,
  dependency('appindicator3-0.1'),
  indicator_kdeconnect_dep
]

module_source = ['main.vala', 
                 'kdeconnectmanager.vala', 
                 'device.vala',
                 'devicemanager.vala']

module_exec = executable(module_exec_name, 
                         sources: module_source,
                         dependencies : module_deps,
                         install: true)
