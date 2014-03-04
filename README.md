# DNS

Create DNS records on a variety of providers and 
create DNS records for your nodes automatically.

## Recipes

* `default` create DNS entry for current node
* `fqdn` updates node fqdn and hosts file
* `chef-client` updates the chef-client config resource to include original node name

## LWRP

* actions: `:create`, `:destroy`

### Example

```ruby
dns 'dns.example.org' do
  credentials :some_cloud_token => '[TOKEN]', :some_cloud_key => '[KEY]'
  dns_provider 'some_cloud'
  entry_value '127.0.2.2'
  domain 'example.org'
end
```

## Attributes

* `node[:dns][:provider]` - dns provider name (must be fog compatible)
* `node[:dns][:domain]` - domain of the record
* `node[:dns][:credentials]` - hash of connection credentials (must be fog compatible)
* `node[:dns][:disable]` - disable creation of node dns record
* `node[:dns][:entry][:name]` - dns entry name
* `node[:dns][:entry][:type]` - dns entry type
* `node[:dns][:entry][:value]` - dns entry value
* `node[:dns][:chef_client_config]` - automatically include `dns::chef-client` recipe

# Infos
* Repository: https://github.com/hw-cookbooks/dns
* IRC: Freenode @ #heavywater
* Cookbook: http://ckbk.it/dns
