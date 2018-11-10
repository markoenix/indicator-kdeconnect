# Modules Target

modules_deps = [
  dependency('gtk+-3.0'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0')
]

module_template = files('module.in')

module_list = [  
  'common',
  'indicator',    
  'extensions'
]

foreach module : module_list
  subdir(module)
endforeach

#install_data(['helper.py', '__init__.py'], install_dir: plugin_subdir)