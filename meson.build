project('indicator-kdeconnect', 
        'vala', 
        'c',
        version : '0.9.4',
        license : 'GPL-2.1+')

# Project web site
project_web = 'https://github.com/Bajoja/indicator-kdeconnect'
# Where to report bugs; usually either an e-mail address or an issue
# tracker URL.
project_bugs = 'https://github.com/Bajoja/indicator-kdeconnect/issues'

short_description = 'AppIndicator for KDEConnect'

api_version = '1.3'

ver_arr = meson.project_version().split('.')

as_major_version = ver_arr[0]
as_minor_version = ver_arr[0]
as_micro_version = ver_arr[0]

add_project_arguments('--enable-checking', 
                      language : 'vala')

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), 
                      language : 'c')

buildtype = get_option('buildtype')

if buildtype.startswith('debug')
    message('Build type: @0@'.format(buildtype))
    add_global_arguments('--define=DEBUG_BUILD', language : 'vala')
endif

executable_subdir = join_paths(get_option('datadir'), 
                               meson.project_name())

# The name of the shared library.  Note that a "lib" prefix will be
# added automatically on systems where that is the convention.
package_name = meson.project_name() + '-' + api_version

meson_dir = meson.current_source_dir()

# Name of the GObject Introspection repository for the library.
gir_name = 'indicator-kdeconnect-' + api_version

subdir('src')

subdir('data')

xgettext = find_program('xgettext', required : false)
if xgettext.found()
  subdir('po')
endif

doc_subdir = join_paths(get_option('datadir'), 
                        'doc', 
                        meson.project_name())

install_data('CHANGES.md', 
             'README.md',
             install_dir: doc_subdir)

licenses_subdir = join_paths(get_option('datadir'), 
                             'licenses', 
                             meson.project_name())

install_data('COPYING',
             install_dir: licenses_subdir)