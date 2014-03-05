# Add/Update DNS entry in DNSMadeEasy.

dns 'DME Node DNS entry' do
  provider "dns_dnsmadeeasy"
  domain node[:dns][:domain]
  entry_name lazy{ node[:dns][:entry][:name] }
  entry_value node[:dns][:entry][:value]
  type node[:dns][:entry][:type]
  ttl node[:dns][:entry][:ttl]
end
