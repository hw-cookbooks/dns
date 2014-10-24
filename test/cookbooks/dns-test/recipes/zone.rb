include_recipe 'dns::fog'

require 'rubygems'
require 'fog'

dns = Fog::DNS.new({
  :provider     => 'AWS',
  :aws_access_key_id => node['dns-test']['access_key'],
  :aws_secret_access_key => node['dns-test']['secret_key']
})

dns.zones.create(
  :domain => 'test.com',
  :email  => 'admin@example.com'
)
