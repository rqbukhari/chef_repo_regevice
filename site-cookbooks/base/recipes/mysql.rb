#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Set the global DB for db type
node.normal[:db_type] = 'mysql'

db_pass = node[:mysql][:password]

# Check for the password
db_pass = secure_password unless db_pass

node.normal[:mysql][:server_root_password] = db_pass
node.normal[:mysql][:server_repl_password] = db_pass
node.normal[:mysql][:server_debian_password] = db_pass

# Install MySql
include_recipe 'mysql::server'
include_recipe 'mysql::client'


# Create and setup DB users
include_recipe "database::mysql"
db_users = node[:mysql][:users].keys
db_connection = {:host => "localhost", :username => 'root', :password => db_pass}
db_users.each do |db_user|
	mysql_database_user db_user do 
		connection db_connection
		password node[:mysql][:users][db_user][:password]
		action :create
	end

	node[:mysql][:users][db_user][:databases].each do |db|
		mysql_database db do
			connection db_connection
			action :create
		end

		mysql_database_user db_user do 
			connection db_connection 
			database_name db 
			privileges [:all] 
			action :grant 
		end
	end
end