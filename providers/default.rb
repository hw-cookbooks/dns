def load_current_resource
  new_resource.entry_name new_resource.name unless new_resource.entry_name
  new_resource.credentials node[:dns][:credentials] unless new_resource.credentials
  new_resource.provider node[:dns][:provider] unless new_resource.provider
end

action :create do
  zone = connection.zones.detect do |z|
    z.domain == new_resource.domain
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
    diff = args.keys.detect do |k|
      record.send(k) != args[k]
    end
    if(diff)
      Chef::Log.debug "DNS diff detected on attribute #{k}. Updating. (#{args.inspect})"
      record.update(args)
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.debug "DNS entry not found. Creating. (#{args.inspect})"
    zone.records.create(args)
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  zone = connection.zones.detect do |z|
    z.domain == new_resource.domain
  end
  record = zone.records.detect do |r|
    r.name == new_resource.entry_name
  end
  if(record)
    record.destroy
    new_resource.updated_by_last_action(true)
  end
end

def connection
  @con ||= CookbookDNS.fog(
    Mash.new(:provider => new_resource.provider).merge(
      new_resource.credentials
    ).to_hash
  )
end
