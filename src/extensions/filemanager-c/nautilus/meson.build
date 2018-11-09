lib_deps = [
  dependency('glib-2.0'),
  dependency('libconfig'),
  dependency('libnautilus-extension')
  #, import('i18n')
]

extensiondir = join_paths(get_option('libdir'), 'nautilus/extensions-3.0')

sendvia_kdeconnect_sources = [
  'sendvia-kdeconnect.c',
  'sendvia-kdeconnect.h',
  'sendvia-kdeconnect-module.c'
]

libsendvia_kdeconnect = shared_module(
  'sendvia_kdeconnect',
  sendvia_kdeconnect_sources,
  dependencies : lib_deps,
  install: true,
  install_dir: extensiondir
)
