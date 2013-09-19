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
    diff = args.keys.find_all do |k|
      record.send(k) != args[k]
    end
    if diff.empty?
      Chef::Log.info "No update required for DNS entry: #{new_resource.entry_name}"
    else
      Chef::Log.info "Updating DNS entry: #{new_resource.entry_name} -> #{diff.map{|k| "#{k}:#{args[k]}"}.join(', ')}"
      if record.is_a?(Fog::DNS::Linode::Record)
        linode_update(record, args)
      else
        record.update(args)
      end
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
    z.domain == new_resource.domain
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
  @con ||= CookbookDNS.fog(
    {:provider => new_resource.provider}.merge(new_resource.credentials).to_hash
  )
end

def linode_update(record, args)
  args.each { |key, value| record.send("#{key}=", value) }
  record.save
end
