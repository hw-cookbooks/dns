default[:dns][:provider] = node[:cloud][:provider]
default[:dns][:domain] = node[:domain]
default[:dns][:credentials] = {}
default[:dns][:disable] = !node[:cloud]
default[:dns][:entry][:name] = node[:fqdn]
default[:dns][:entry][:type] = 'A'
default[:dns][:entry][:value] = node[:ipaddress]
default[:dns][:chef_client_config] = false
