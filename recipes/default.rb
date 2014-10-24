require 'resolv'

include_recipe 'dns::fog'

ruby_block 'Set dns name attribute' do
  block do
    node.default[:dns][:entry][:name] = [node.name, node[:dns][:domain]].join('.')
  end
end

dns 'Node DNS entry' do
  entry_name lazy{ node[:dns][:entry][:name] }
  entry_value node[:dns][:entry][:value]
  domain node[:dns][:domain]
  type node[:dns][:entry][:type]
  ttl node[:dns][:entry][:ttl]
  not_if do
    node[:dns][:disable] ||
    begin
      existing = Resolv::DNS.new(
        :nameserver => File.readlines('/etc/resolv.conf').find_all{|s|
          s.start_with?('nameserver')
        }.map{|s|s.split.last}.uniq
      ).getaddress(node[:dns][:entry][:name]).to_s
      existing == node[:dns][:entry][:value]
    rescue Resolv::ResolvError
      false
    end
  end
end

if(node[:dns][:chef_client_config])
  include_recipe 'dns::chef-client'
end
