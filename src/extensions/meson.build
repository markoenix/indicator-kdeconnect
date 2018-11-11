# Extension Target
extension_list = [  
  'sms',
  'generic'
]

if get_option('extensions') == 'c'
  extension_list += ['filemanager-c']
elif get_option('extensions') == 'python'
  extension_list += ['filemanager-python']
endif

foreach module : extension_list
  subdir(module)
endforeach