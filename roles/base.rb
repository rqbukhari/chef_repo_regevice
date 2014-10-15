name 'base'
description 'Base bootstrap for every box'
run_list 'recipe[base]'
default_attributes(
  'base' => {
    'users' => ['deploy']
  }
)