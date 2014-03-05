include_recipe 'dns::fog'

require 'rubygems'
require 'fog'

dns = Fog::DNS.new({
  :provider     => 'aws',
  :aws_access_key_id => node['fake']['access_key'],
  :aws_secret_access_key => node['fake']['secret_key']
})

dns.zones.create(
  :domain => 'test.com',
  :email  => 'admin@example.com'
)
