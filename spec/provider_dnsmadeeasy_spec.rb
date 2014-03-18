require 'spec_helper'

describe 'Run DNSMadeEasy provider' do

  let(:domain) { 'test.com' }
  let(:name) { 'www' }
  let(:initial_value) { '10.0.0.1' }
  let(:updated_value) { '192.168.1.1' }
  let(:ttl) { 60 }
  let(:type) { 'A' }

  let(:rest_client) do
    client_stub = double("RestClient::Resource")
    client_stub.stub(:[]).and_return(client_stub)
    client_stub.stub(:get).and_return(client_stub)
    client_stub.stub(:post).and_return(client_stub)
    client_stub.stub(:put).and_return(client_stub)
    client_stub.stub(:delete).and_return(client_stub)
    client_stub
  end

  before(:each) do
    RestClient::Resource.stub(:new).and_return(rest_client)
  end

  let(:chef_run) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.node.set[:dns][:entry][:value] = initial_value
    runner.node.set[:dns][:entry][:type] = type
    runner.node.set[:dns][:entry][:ttl] = ttl
    runner.converge('fake::dme')
  end

  let(:chef_run_dns_disable) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:disable] = true
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.node.set[:dns][:entry][:value] = initial_value
    runner.node.set[:dns][:entry][:type] = type
    runner.node.set[:dns][:entry][:ttl] = ttl
    runner.converge('fake::dme')
  end

  let(:chef_run_delete) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:domain] = domain
    runner.node.set[:dns][:entry][:name] = name
    runner.converge('fake::dme_delete')
  end

  it 'creates a new record using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to receive(:post).and_return(nil)
    chef_run
  end

  it 'updates an existing record using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"#{updated_value}","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to receive(:put).and_return(nil)
    chef_run
  end

  it 'does no update to an existing record using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"#{initial_value}","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to_not have_received(:post)
    expect(rest_client).to_not have_received(:put)
    chef_run
  end

  it 'does not create a record if it is missing when updating using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to_not have_received(:post)
    expect(rest_client).to_not have_received(:put)
    chef_run_dns_disable
  end

  it 'deletes a record using using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"192.168.1.2","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to receive(:delete).and_return(nil)
    chef_run_delete
  end

  it 'attempts to delete a record that does not exist using dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to_not have_received(:delete)
    chef_run_delete
  end

end
