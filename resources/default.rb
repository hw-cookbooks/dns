# Actions to create/update and destroy a DNS entry.
actions :create, :destroy
default_action :create

# Name of the DNS record in domain/zone to manage. Ex: www
attribute :entry_name, :kind_of => String

# Value to give to the DNS record. For A records, it should be an IP.
attribute :entry_value, :kind_of => String, :required => true

# Credentials for the DNS provider account. The hash key names are specific
# in Fog for each DNS provider:
# https://github.com/fog/fog/blob/master/lib/fog/{PROVIDER}/dns.rb
attribute :credentials, :kind_of => Hash

# DNS provider name used by Fog:
# http://fog.io/about/provider_documentation.html
attribute :dns_provider, :kind_of => String

# Domain/zone name to place :entry_name in. Ex: example.com
attribute :domain, :kind_of => String

# DNS record type. Ex: 'A', 'CNAME'
attribute :type, :kind_of => String, :required => true, :default => 'A'

# Time To Live DNS property to give to entry.
attribute :ttl, :kind_of => Numeric

# Priority number used by specific DNS types, such as MX.
attribute :priority, :kind_of => Numeric

# Set to true will only update the DNS record. Will not create it if it does not exist.
attribute :dns_create_disable, :kind_of => [TrueClass, FalseClass], :default => false
