#
# Cookbook Name:: glance
# Recipe:: api
#
#

include_recipe "#{@cookbook_name}::common"


# Need to figure out environment filter
keystones = search(:node, "recipes:keystone\\:\\:server") || []
if keystones.length > 0
  keystone = keystones[0]
else
  keystone = node
end

keystone_address = Chef::Recipe::Barclamp::Inventory.get_network_by_type(keystone, "admin").address if keystone_address.nil?
Chef::Log.info("Keystone server found at #{keystone_address}")

template node[:glance][:api][:config_file] do
  source "glance-api.conf.erb"
  owner node[:glance][:user]
  group "root"
  mode 0644
  variables(
    :keystone_address = keystone_address,
    :keystone_admin_token => keystone[:keystone][:dashboard]['long-lived-token']
  )
end

glance_service "api"

node[:glance][:monitor][:svcs] <<["glance-api"]

