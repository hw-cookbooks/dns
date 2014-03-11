require 'spec_helper'

describe 'fake::dme' do

  let(:rest_client) do
    client_stub = double("RestClient::Resource")
    client_stub.stub(:[]).and_return(client_stub)
    client_stub
  end

  before(:each) do
    RestClient::Resource.stub(:new).and_return(rest_client)
  end

  let(:chef_run) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = "test.com"
    runner.node.set[:dns][:entry][:name] = "www"
    runner.node.set[:dns][:entry][:value] = "10.0.0.1"
    runner.node.set[:dns][:entry][:type] = "A"
    runner.node.set[:dns][:entry][:ttl] = 60
    runner.converge(described_recipe)
  end

  # TODO 
  #  - add verification of auth_headers
  #  - context block to handle if we need to update or add entry
  #  - Check node[:dns][:disable] is enabled

  it 'installs entry in dnsmadeeasy v2.0' do
    rest_client.should_receive(:get).exactly(2).and_return(
      '{"data":[{"name":"test.com","id":334721,"created":1192147200000}]}',
      '{"data":[{"name":"101test1403","value":"192.168.1.2","id":14101880,"type":"A","ttl":60}]}'
    )
    rest_client.should_receive(:put).and_return(nil)
    rest_client.should_receive(:post).and_return(nil)
    chef_run
  end

end
