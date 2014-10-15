name 'web'
description 'Install configure web server NGINX or Apache'
run_list 'recipe[base::web]'
default_attributes('ruby' => { 'version' => '2.1.3' }, 'nginx'=>{'gzip'=>'on'})