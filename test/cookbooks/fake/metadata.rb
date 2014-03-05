name             'fake'
version          '0.1.0'

depends 'dns'

recipe 'fake::create_zone', 'Creates a DNS zone'
recipe 'fake::update', 'Updates a DNS entry'
recipe 'fake::delete', 'Delete DNS entry'
recipe 'fake::fog_mock', 'Turn on Fog mock'
