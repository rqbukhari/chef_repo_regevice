

# Install the rbenv
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

# Install ruby
rbenv_ruby node["ruby"]["version"] do 
	global true
end

# Install bundler to be used for application packages
rbenv_gem "bundler" do
  ruby_version node["ruby"]["version"]
end