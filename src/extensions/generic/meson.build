extensiondir = get_option('datadir')

if run_command('test', '-d', join_paths(extensiondir, 'Thunar/sendto')).returncode() == 0
    install_data(sources : 'sendvia-kdeconnect.desktop', 
                 install_dir : join_paths(get_option('datadir'), 'Thunar/sendto'))
endif

if run_command('test', '-d', join_paths(extensiondir, 'contractor')).returncode() == 0
    install_data(sources : 'sendvia-kdeconnect.contract',
                 install_dir : join_paths(get_option('datadir'), 'contractor'))
endif