require 'spec_helper'
require 'fog'

provider = 'AWS'
domain = 'test.com.'
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

  it 'creates a new dns record' do
    chef_run_create

    zone = dns.zones.detect do |z|
      z.domain == domain
    end
    expect(zone).to_not be_nil

    record = zone.records.detect do |r|
      r.name == name
    end
    expect(record).to_not be_nil

    # Verify created record
    expect(record.name).to eq(name)
    expect(record.value).to eq([initial_value])
    expect(record.ttl).to eq(ttl.to_s)
    expect(record.type).to eq(type)
  end

  it 'updates existing dns record' do
    chef_run_update

    zone = dns.zones.detect do |z|
      z.domain == domain
    end
    expect(zone).to_not be_nil

    record = zone.records.detect do |r|
      r.name == name
    end
    expect(record).to_not be_nil

    # Verify updated record
    expect(record.name).to eq(name)
    expect(record.value).to eq([updated_value])
    expect(record.ttl).to eq(ttl.to_s)
    expect(record.type).to eq(type)
  end

  it 'deletes a dns record' do
    chef_run_delete

    zone = dns.zones.detect do |z|
      z.domain == domain
    end
    expect(zone).to_not be_nil

    record = zone.records.detect do |r|
      r.name == name
    end
    expect(record).to be_nil
  end

end
