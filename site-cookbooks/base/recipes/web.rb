
if node["web"]["server"] == "nginx"
	include_recipe "nginx::default"
	include_recipe "nginx::repo"
end