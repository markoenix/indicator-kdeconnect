# Executable type

sms_config_path = join_paths(get_option('config_folder'), 
                             meson.project_name(), 
                             'sms')

run_command('mkdir', sms_config_path)

install_data('sms.py', 
             install_dir: sms_config_path)               
