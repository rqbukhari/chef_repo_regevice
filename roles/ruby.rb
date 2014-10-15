name 'ruby'
description 'Install the specific versions of ruby'
run_list 'recipe[base::ruby]'
default_attributes('ruby' => { 'version' => '2.1.3' })