# Ensure we have our entry name defaulted
node.default[:dns][:entry][:name] = [node.name, node[:dns][:domain]].join('.')

# Set desired hostname and fqdn based on entry name
node.set[:hosts_file][:hostname] = node[:dns][:entry][:name].split('.').first
node.set[:hosts_file][:fqdn] = node[:dns][:entry][:name]

include_recipe 'hosts_file'

template 'fqdn_set_hosts_file' do
  source 'hosts.erb'
  path node[:hosts_file][:path]
  mode 0644
  action :nothing
  not_if do
    node[:fqdn] == node[:dns][:entry][:name]
  end
end.run_action(:create)

file '/etc/hostname' do
  content "#{node[:hosts_file][:hostname]}\n"
end

execute "Set hostname to #{node[:hosts_file][:hostname]}" do
  action :nothing
  command "hostname #{node[:hosts_file][:hostname]}"
  not_if "hostname | grep #{node[:hosts_file][:hostname]}"
end.run_action(:run)

ohai 'fqdn' do
  action :nothing
end.run_action(:reload)

