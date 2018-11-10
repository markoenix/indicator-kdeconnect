icondir = join_paths(get_option('datadir'), 'icons')

install_subdir('Adwaita', 
               install_dir : icondir)

if run_command('test', '-d', join_paths(icondir, 'ubuntu-mono-dark')).returncode() == 0
    install_subdir('ubuntu-mono-dark', 
                   install_dir : icondir)
endif

if run_command('test', '-d', join_paths(icondir, 'ubuntu-mono-light')).returncode() == 0
    install_subdir('ubuntu-mono-light', 
                   install_dir : icondir)
endif

if run_command('test', '-d', join_paths(icondir, 'elementary')).returncode() == 0
    install_subdir('elementary', 
                   install_dir : icondir)
endif

if run_command('gtk-update-icon-cache', '-t', '-f', icondir).returncode() == 0
     message('Update icons cache')
endif