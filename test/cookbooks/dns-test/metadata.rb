name             'dns-test'
version          '0.1.0'

depends 'dns'
depends 'hosts_file', '~> 0.1.4'

recipe 'dns-test::zone', 'Creates a DNS zone'
recipe 'dns-test::update', 'Updates a DNS entry'
recipe 'dns-test::delete', 'Delete DNS entry'
recipe 'dns-test::fog_mock', 'Turn on Fog mock'
recipe 'dns-test::dme', 'Create DNS entry in DME'
recipe 'dns-test::dme_delete', 'Delete DNS entry in DME'
