name 'web'
description 'Install configure web server NGINX or Apache'
run_list "recipe[base::web]"
default_attributes("ruby" => { "version" => "1.9.3-p448" }, "nginx"=>{"gzip"=>"on"})