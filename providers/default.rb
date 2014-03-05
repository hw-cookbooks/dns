def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.dns_provider node[:dns][:provider] unless new_resource.dns_provider
end

action :create do
  zone = connection.zones.detect do |z|
    z.domain =~ /^#{new_resource.domain}\.{0,1}$/
  end
  record = zone.records.detect do |r|
    r.name == new_resource.entry_name
  end
  args = Mash.new(
    :value => new_resource.entry_value,
    :name => new_resource.entry_name,
    :type => new_resource.type.upcase
  )
  args[:ttl] = new_resource.ttl if new_resource.ttl
  args[:priority] = new_resource.priority if new_resource.priority
  if(record)
    diff = args.keys.find_all do |k|
      record.send(k) != args[k]
    end
    unless(diff.empty?)
      record.modify(args)
      Chef::Log.info "Updated DNS entry: #{new_resource.entry_name} -> #{diff.map{|k| "#{k}:#{args[k]}"}.join(', ')}"
      new_resource.updated_by_last_action(true)
    end
  else
    zone.records.create(args)
    Chef::Log.info "Created DNS entry: #{new_resource.entry_name} -> #{new_resource.entry_value}"
    new_resource.updated_by_last_action(true)
  end
end

action :destroy do
  zone = connection.zones.detect do |z|
    z.domain =~ /^#{new_resource.domain}\.{0,1}$/
  end
  record = zone.records.detect do |r|
    r.name == new_resource.entry_name
  end
  if(record)
    record.destroy
    Chef::Log.info "Destroying DNS entry: #{new_resource.entry_name}"
    new_resource.updated_by_last_action(true)
  end
end

def connection
  @con ||= CookbookDNS.fog(new_resource.credentials.merge(:provider => new_resource.dns_provider))
end

