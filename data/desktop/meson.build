applicationsdir = join_paths(get_option('datadir'),
                             'applications')

configure_file(output: 'indicator-kdeconnect.desktop',
               input: 'indicator-kdeconnect.desktop.in',
               configuration: indicator_kdeconnect_conf,
               install_dir: applicationsdir)

configure_file(output: 'settings-indicator-kdeconnect.desktop',
               input: 'settings-indicator-kdeconnect.desktop.in',
               configuration: indicator_kdeconnect_conf,
               install_dir: applicationsdir)