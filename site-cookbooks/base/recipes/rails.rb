#
# Cookbook Name:: base
# Recipe:: rails
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

#Installing bluepill gem
rbenv_gem "bluepill" do
  ruby_version node["ruby"]["version"]
end

# Setting default values
applications_root = node[:rails][:applications_root]
applications = node[:rails][:applications]

# Installing application specific packages
if applications
	applications.each do |app, app_info|
		if app_info['packages']
			app_info['packages'].each do |package|
				package package
			end
		end
	end
end


# Setting up applications
if applications
	applications.each do |app, app_info|
		rails_env = app_info['rails_env'] || 'production'
		deploy_user = app_info['deploy_user'] || 'deploy'
		app_env = app_info['app_env'] || {}
		app_env['RAILS_ENV'] = rails_env

		rbenv_ruby node[:ruby][:version]

		rbenv_gem 'bundler' do
			ruby_version node[:ruby][:version]
		end

		directory "#{applications_root}/#{app}" do
			recursive true
			group deploy_user
			owner deploy_user
		end

		['config', 'shared', 'shared/config', 'shared/sockets', 'shared/pids', 'shared/log', 'shared/system', 'releases'].each do |dir|
			directory "#{applications_root}/#{app}/#{dir}" do
				recursive true
				group deploy_user
				owner deploy_user
			end
		end

		# Load default information by convention
		db_info = {}.merge(app_info['database_info'])
		if db_info
			if node[:db_type] == 'mysql'
				db_info['adapter'] = 'mysql2'
				db_info['host'] = node[:mysql][:bind_address] unless db_info['host']
				db_info['username'] = node[:mysql][:users].map{|user, info| user if info[:databases].include?(db_info['database']) }.reject{|a| a.nil?}.first unless db_info['username']
				db_info['password'] = node[:mysql][:users].map{|user, info| info[:password] if info[:databases].include?(db_info['database']) }.reject{|a| a.nil?}.first unless db_info['password']
				db_info['pool'] = 5 unless db_info['pool']
				db_info['timeout'] = 5000 unless db_info['timeout']
			end

			# Creating database.yml
			template "#{applications_root}/#{app}/shared/config/database.yml" do
				owner deploy_user
				group deploy_user
				mode 0600
				source 'database.yml.erb'
				variables :database_info => db_info, :rails_env => rails_env
			end
		end


		# Loading up SSL Information
		if app_info['ssl_info']
			template "#{applications_root}/#{app}/shared/config/certificate.crt" do
				owner "deploy"
				group "deploy"
				mode 0644
				source "app_cert.crt.erb"
				variables :app_crt=> app_info['ssl_info']['crt']
			end

			template "#{applications_root}/#{app}/shared/config/certificate.key" do
				owner "deploy"
				group "deploy"
				mode 0644
				source "app_cert.key.erb"
				variables :app_key=> app_info['ssl_info']['key']
			end
		end


		# Setting up Nginx site
		if node["web"]["server"] == "nginx"
			# Enable and set the Nginx
			template "/etc/nginx/sites-available/#{app}.conf" do
				source 'app_nginx.conf.erb'
				variables :name => app, :domain_names => app_info['domain_names'], :applications_root=> applications_root, :enable_ssl => File.exists?("#{applications_root}/#{app}/shared/config/certificate.crt")
				notifies :reload, resources(:service => "nginx")
			end
		end

		# Setting up puma configuration
		template "#{applications_root}/#{app}/shared/config/puma.rb" do
			mode 0644
			source 'app_puma.rb.erb'
			variables(
				:name => app,
				:rails_env=>rails_env,
				:deploy_user => deploy_user,
				:applications_root=> applications_root,
				:number_of_workers => app_info['number_of_workers'] || 2,
				:min_threads => app_info['min_threads'] || 3,
				:max_threads => app_info['max_threads'] || 10
			)
		end


		template "#{node[:bluepill][:conf_dir]}/#{app}.pill" do
			mode 0644
			source "bluepill_puma.rb.erb"
			variables(
				:name => app,
				:deploy_user => deploy_user,
				:app_env => app_env,
				:rails_env => rails_env, 
				:applications_root => applications_root
			)
		end

		bluepill_service app do
			action [:enable, :load, :start]
		end

		template "/etc/init/#{app}.conf" do
			mode 0644
			source "bluepill_upstart.erb"
			variables :name => app
		end

		service "#{app}" do
			provider Chef::Provider::Service::Upstart
			action [ :enable ]
		end

		nginx_site "#{app}.conf" do
			action :enable
		end

		logrotate_app "rails-#{app}" do
			cookbook 'logrotate'
			path ["#{applications_root}/#{app}/current/log/*.log"]
			frequency "daily"
			rotate 14
			compress true
			create "644 #{deploy_user} #{deploy_user}"
		end
	end
end
