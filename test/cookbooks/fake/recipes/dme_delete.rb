# Delete DNS entry in DNSMadeEasy.

dns 'Delete DNS entry' do
  provider "dns_dnsmadeeasy"
  domain node[:dns][:domain]
  entry_name lazy{ node[:dns][:entry][:name] }
  action :destroy
end
