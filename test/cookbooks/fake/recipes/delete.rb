# Delete DNS entry

dns 'Delete DNS entry' do
  dns_provider 'aws'
  domain 'test.com'
  entry_name '101test'
  action :destroy
end
