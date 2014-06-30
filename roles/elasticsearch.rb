name 'elasticsearch'
description 'Elastic Search Full Text Search server for apps'
run_list "recipe[java::default]", "recipe[elasticsearch]"
default_attributes(
	"java" => {
		"install_flavor" => "openjdk",
		"jdk_version" => "7"
	},
	"elasticsearch" => {
		"cluster"  => { "name" => "elasticsearch_base" },
		"version" => "1.0.1",		
		"allocated_memory" => "256m"
	})