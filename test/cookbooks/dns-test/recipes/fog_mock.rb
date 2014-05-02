include_recipe 'dns::fog'

require 'fog'

# Turn on Fog mocking
Fog.mock!
