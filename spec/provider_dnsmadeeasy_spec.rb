require 'spec_helper'

domain = 'test.com'
name = 'www'
initial_value = '10.0.0.1'
updated_value = '192.168.1.1'
ttl = 60
type = 'A'

describe 'Run DNSMadeEasy provider' do

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

  it 'add entry in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to receive(:post).and_return(nil)
    chef_run
  end

  it 'update entry in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"#{updated_value}","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to receive(:put).and_return(nil)
    chef_run
  end

  it 'no update required of entry in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"#{initial_value}","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to_not have_received(:post)
    expect(rest_client).to_not have_received(:put)
    chef_run
  end

  it 'only updating of entry if exists in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to_not have_received(:post)
    expect(rest_client).to_not have_received(:put)
    chef_run_dns_disable
  end

  it 'deleting entry in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[{"name":"#{name}","value":"192.168.1.2","id":12345678,"type":"#{type}","ttl":#{ttl}}]}]
    )
    expect(rest_client).to receive(:delete).and_return(nil)
    chef_run_delete
  end

  it 'attempt deleting entry that does not exist in dnsmadeeasy v2.0' do
    expect(rest_client).to receive(:get).exactly(2).and_return(
      %Q[{"data":[{"name":"#{domain}","id":123456,"created":1192147200000}]}],
      %Q[{"data":[]}]
    )
    expect(rest_client).to_not have_received(:delete)
    chef_run_delete
  end

end
