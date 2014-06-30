name 'mysql'
description 'MySQL server for apps'
run_list "recipe[build-essential]", "recipe[postgresql::server]", "recipe[postgresql::client]"
default_attributes("postgresql" => { "config" =>{ "listen_addresses" => "127.0.0.1" }})