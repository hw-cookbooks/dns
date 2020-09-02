node.normal['build_essential'][:compiletime] = true
build_essential 'install compilation tools'

# Dependencies required by nokogiri (for fog)
%w(libxslt-dev libxml2-dev).each do |pkg|
  c_pkg = package(pkg)
  c_pkg.run_action(:install)
end

# TODO: Remove this once the gem_hell cookbook is ready to roll
chef_gem 'fog' do
  version '1.10.1'
  action :install
end
