extensiondir = get_option('datadir')

if run_command('test', '-d', join_paths(extensiondir, 'caja-python/extensions')).returncode() == 0
    install_data(sources : 'caja/kdeconnect-send.py', 
                 install_dir : join_paths(get_option('datadir'), 'caja-python/extensions'))
endif

if run_command('test', '-d', join_paths(extensiondir, 'nautilus-python/extensions')).returncode() == 0
    install_data(sources : 'nautilus/kdeconnect-send.py',
                 install_dir : join_paths(get_option('datadir'), 'nautilus-python/extensions'))
endif

if run_command('test', '-d', join_paths(extensiondir, 'nemo-python/extensions')).returncode() == 0
    install_data(sources : 'nemo/kdeconnect-send.py',
                 install_dir : join_paths(get_option('datadir'), 'nemo-python/extensions'))
endif