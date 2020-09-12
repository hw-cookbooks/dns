include_recipe 'chef-client::config'

# Force chef-client config to use node name
begin
  client_config = node.run_context.resource_collection.lookup("template[#{node['chef_client']['conf_dir']}/client.rb]")
  client_config.variables.update(chef_node_name: Chef::Config[:node_name])
rescue => e
  Chef::Log.warn "Failed to locate chef client.rb template resource. If client.rb is managed, please check why it cannot be found: #{e}"
end
