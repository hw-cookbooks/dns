# Delete DNS entry

dns 'Delete DNS entry' do
  dns_provider 'AWS'
  domain 'test.com'
  entry_name 'www'
  action :destroy
end
