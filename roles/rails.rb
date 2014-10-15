name 'rails'
description 'Install the rails specifc file structure and necessary items'
run_list 'recipe[bluepill::default]', 'recipe[base::rails]'
default_attributes(
	'rails' => {
		'application_root' => '/home/deploy/',
		'applications' => {}
})
