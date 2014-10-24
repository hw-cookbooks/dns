# Add/Update DNS entry in DNSMadeEasy.

dns 'DME Node DNS entry' do
  provider "dns_dnsmadeeasy_api20"
  domain node[:dns][:domain]
  credentials(
    'dnsmadeeasy_api_key' => node['dns-test']['access_key'],
    'dnsmadeeasy_secret_key' => node['dns-test']['secret_key'],
  )
  entry_name node[:dns][:entry][:name]
  entry_value node[:dns][:entry][:value]
  type node[:dns][:entry][:type]
  ttl node[:dns][:entry][:ttl]
end
