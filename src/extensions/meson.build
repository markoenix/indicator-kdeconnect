#
#
# Extension Target
extension_list = [  
  'sms',
  'generic'
]

if get_option('extensions') == 'c'
  extension_list += ['filemanager-c']
else
  extension_list += ['filemanager-python']
endif

foreach module : extension_list
  subdir(module)
endforeach

#install_data(['helper.py', '__init__.py'], install_dir: plugin_subdir)
