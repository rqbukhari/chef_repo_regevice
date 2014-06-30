name 'ruby'
description 'Install the specific versions of ruby'
run_list "recipe[base::ruby]"
default_attributes("ruby" => { "version" => "1.9.3-p448" })