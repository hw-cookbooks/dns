# Changes IP from 192.168.1.1 to 192.168.200.200

dns 'Fake DNS update' do
  dns_provider 'aws'
  entry_name '101test'
  domain 'test.com'
  entry_value '192.168.200.200'
  type 'A'
  ttl 60
end
