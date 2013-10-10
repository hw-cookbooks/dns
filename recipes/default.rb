require 'resolv'

include_recipe 'dns::fog'

ruby_block 'Apply DNS information' do
  block do
    require 'fog'

    node.default[:dns][:entry][:name] = [node.name, node[:dns][:domain]].join('.')
    if node[:ec2]
      node.set[:dns][:entry][:value] = node[:ec2][:public_hostname]
      node.set[:dns][:entry][:type] = 'CNAME'
    end
    con = Fog::DNS.new(Mash.new(:provider => node[:dns][:provider]).merge(node[:dns][:credentials].to_hash))

    if node[:dns][:credentials][:provider] == "AWS"
      domain = con.list_hosted_zones.data[:body]['HostedZones'].detect do |domain_hash|
        domain_hash['Name'] == "#{node[:dns][:domain]}."
      end
      zone = con.zones.get(domain['Id'])
    else
      domain = con.list_domains.body['domains'].detect do |domain_hash|
        domain_hash['name'] == node[:dns][:domain]
      end
      raise "Failed to locate registered domain in account for configured domain: #{node[:dns][:domain]}" unless domain
      zone = con.zones.get(domain['id'])
      raise "Failed to locate zone for configured domain: #{node[:dns][:domain]}" unless zone
    end

    record = zone.records.detect do |r|
      r.name =~ /^#{node[:dns][:entry][:name]}.?$/
    end

    if record
      Chef::Log.info "DNS - Found existing record for: #{node[:dns][:entry][:name]}. Updating."
      Chef::Log.info "DNS - Existing type: #{record.type} Existing value: #{record.value}"
      record.value = node[:dns][:entry][:value]
      record.type = node[:dns][:entry][:type].upcase
      record.save
    else
      Chef::Log.info "DNS - No existing record found for #{node[:dns][:entry][:name]}. Creating."
      zone.records.create(
        :value => node[:dns][:entry][:value],
        :name => node[:dns][:entry][:name],
        :type => node[:dns][:entry][:type].upcase
      )
    end
    Chef::Log.info "DNS - Record saved: name: #{node[:dns][:entry][:name]} type: #{node[:dns][:entry][:type]} value: #{node[:dns][:entry][:value]}"
  end
  not_if do
    node[:dns][:disable] ||
    begin
      resolv_opts = { 
        :nameserver => File.readlines('/etc/resolv.conf').find_all{|s|s.start_with?('nameserver')}.map{|s|s.split.last}.uniq
      }
      existing = Resolv::DNS.new(resolv_opts).getaddress(node[:dns][:entry][:name]).to_s
      existing == node[:dns][:entry][:value] || 
        existing == Resolv::DNS.new(resolv_opts).getaddress(node[:dns][:entry][:value]).to_s
    rescue Resolv::ResolvError
      false
    end
  end
end

if(node[:dns][:chef_client_config])
  include_recipe 'dns::chef-client'
end
