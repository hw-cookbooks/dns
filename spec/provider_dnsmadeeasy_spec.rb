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

  let(:chef_run_dns_disable) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:disable] = true
    runner.node.set[:dns][:domain] = "test.com"
    runner.node.set[:dns][:entry][:name] = "www"
    runner.node.set[:dns][:entry][:value] = "10.0.0.1"
    runner.node.set[:dns][:entry][:type] = "A"
    runner.node.set[:dns][:entry][:ttl] = 60
    runner.converge(described_recipe)
  end

  # TODO - add verification of auth_headers

  context "when a dns entry already exists for updating" do
    it 'update entry in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[{"name":"www","value":"192.168.1.2","id":12345678,"type":"A","ttl":60}]}'
      )
      rest_client.should_receive(:put).and_return(nil)
      chef_run
    end
  end

  context "when a dns entry does not need updating" do
    it 'update entry in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[{"name":"www","value":"10.0.0.1","id":12345678,"type":"A","ttl":60}]}'
      )
      rest_client.should_not_receive(:post)
      rest_client.should_not_receive(:put)
      chef_run
    end
  end

  context "when a dns entry should be created" do
    it 'add entry in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[]}'
      )
      rest_client.should_receive(:post).and_return(nil)
      chef_run
    end
  end

  context "when a dns entry does not exist and creation is disabled" do
    it 'only update entry in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[]}'
      )
      rest_client.should_not_receive(:post)
      rest_client.should_not_receive(:put)
      chef_run_dns_disable
    end
  end

end

describe 'fake::dme_delete' do

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
    runner.node.set[:dns][:domain] = "test.com"
    runner.node.set[:dns][:entry][:name] = "www"
    runner.converge(described_recipe)
  end

  context "when a dns entry exists to be deleted" do
    it 'deleting entry in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[{"name":"www","value":"192.168.1.2","id":12345678,"type":"A","ttl":60}]}'
      )
      rest_client.should_receive(:delete).and_return(nil)
      chef_run
    end
  end

  context "when a dns entry does not exist to be deleted" do
    it 'not deleting entry that does not exist in dnsmadeeasy v2.0' do
      rest_client.should_receive(:get).exactly(2).and_return(
        '{"data":[{"name":"test.com","id":123456,"created":1192147200000}]}',
        '{"data":[]}'
      )
      rest_client.should_not_receive(:delete)
      chef_run
    end
  end
end
