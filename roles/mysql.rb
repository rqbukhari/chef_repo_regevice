name 'mysql'
description 'MySQL server for apps'
run_list "recipe[build-essential]", "recipe[base::mysql]"
default_attributes("mysql" => { "bind_address" => "127.0.0.1" })