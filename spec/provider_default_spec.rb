require 'spec_helper'
require 'fog'

provider = 'AWS'
domain = 'test.com'
name = 'www'
initial_value = '10.0.0.1'
updated_value = '192.168.1.1'
ttl = 60
type = 'A'

describe 'Run default provider with AWS' do

  let(:chef_run_create) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:provider] = provider
    runner.node.set[:dns][:credentials] = {:aws_access_key_id => 'MOCK_ACCESS_KEY', :aws_secret_access_key => 'MOCK_SECRET_KEY'}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.node.set[:dns][:entry][:value] = initial_value
    runner.node.set[:dns][:entry][:type] = type
    runner.node.set[:dns][:entry][:ttl] = ttl
    runner.converge('fake::fog_mock', 'fake::zone', 'dns::default')
  end
  let(:chef_run_update) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:provider] = provider
    runner.node.set[:dns][:credentials] = {:aws_access_key_id => 'MOCK_ACCESS_KEY', :aws_secret_access_key => 'MOCK_SECRET_KEY'}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.node.set[:dns][:entry][:value] = updated_value
    runner.node.set[:dns][:entry][:type] = type
    runner.node.set[:dns][:entry][:ttl] = ttl
    runner.converge('dns::default')
  end
  let(:chef_run_delete) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:provider] = provider
    runner.node.set[:dns][:credentials] = {:aws_access_key_id => 'MOCK_ACCESS_KEY', :aws_secret_access_key => 'MOCK_SECRET_KEY'}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.node.set[:dns][:entry][:value] = initial_value
    runner.node.set[:dns][:entry][:type] = type
    runner.node.set[:dns][:entry][:ttl] = ttl
    runner.converge('fake::delete')
  end

  Fog.mock!
  dns = Fog::DNS.new({
    :provider     => provider,
    :aws_access_key_id => 'MOCK_ACCESS_KEY',
    :aws_secret_access_key => 'MOCK_SECRET_KEY'
  })

  it 'check if dns entry was created' do
    chef_run_create

    zone = dns.zones.detect do |z|
      z.domain == 'test.com.'
    end or raise 'zone not created'

    record = zone.records.detect do |r|
      r.name == name
    end or raise 'record not created'

    # Verify created record
    expect(record.name).to eq(name)
    expect(record.value).to eq([initial_value])
    expect(record.ttl).to eq(ttl.to_s)
    expect(record.type).to eq(type)
  end

  it 'check if dns entry was updated' do
    chef_run_update

    zone = dns.zones.detect do |z|
      z.domain == 'test.com.'
    end or raise 'zone not created'

    record = zone.records.detect do |r|
      r.name == name
    end or raise 'record not created'

    # Verify updated record
    expect(record.name).to eq(name)
    expect(record.value).to eq([updated_value])
    expect(record.ttl).to eq(ttl.to_s)
    expect(record.type).to eq(type)
  end

  it 'check if dns entry was deleted' do
    chef_run_delete

    zone = dns.zones.detect do |z|
      z.domain == 'test.com.'
    end or raise 'zone not created'

    record = zone.records.detect do |r|
      r.name == name
    end

    raise 'record was not deleted' if record
  end

end

