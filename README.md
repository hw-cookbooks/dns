# DNS

Create DNS records on a variety of providers and 
create DNS records for your nodes automatically.

## Recipes

* `default` create DNS entry for current node
* `fqdn` updates node fqdn and hosts file
* `chef-client` updates the chef-client config resource to include original node name

## LWRP

* actions: `:create`, `:destroy`

### Examples

```ruby
# Add/update DNS A-record for www.example.org
dns 'www' do
  dns_provider 'DNSProvider'
  domain 'example.org'
  credentials :some_cloud_token => 'TOKEN', :some_cloud_key => 'KEY'
  entry_value '127.0.2.2'
  type 'A'
  ttl 1800
end
```
```ruby
# DNSMadeEasy API2.0 example adding/updating A-record for www2.example.org
dns 'www2' do
  provider 'dns_dnsmadeeasy_api20'
  domain 'example.org'
  credentials :dnsmadeeasy_api_key => 'TOKEN', :dnsmadeeasy_secret_key => 'KEY'
  entry_value '192.168.1.1'
  type 'A'
  ttl 1800
end
```


## Attributes

* `node[:dns][:provider]` - dns provider name used by fog (http://fog.io/about/provider_documentation.html)
* `node[:dns][:domain]` - domain of the record
* `node[:dns][:credentials]` - hash of connection credentials used by fog (https://github.com/fog/fog/blob/master/lib/fog/{provider}/dns.rb)
* `node[:dns][:disable]` - disable creation of node dns record but allow updating if record exists
* `node[:dns][:entry][:name]` - dns entry name
* `node[:dns][:entry][:type]` - dns entry type
* `node[:dns][:entry][:value]` - dns entry value
* `node[:dns][:chef_client_config]` - automatically include `dns::chef-client` recipe

# Infos
* Repository: https://github.com/hw-cookbooks/dns
* IRC: Freenode @ #heavywater
* Cookbook: http://ckbk.it/dns
