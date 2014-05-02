require 'chefspec'
require 'chefspec/librarian'

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.4'
  config.color = true
end
