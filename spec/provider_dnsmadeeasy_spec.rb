require 'spec_helper'

describe 'fake::dme' do

  let(:provider) do
    provider = Chef::Provider::DnsDnsmadeeasyApi20.new(new_resource)
    provider.stub.and_return()
    provider
  end


  let(:chef_run) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:credentials] = {:dnsmadeeasy_api_key => "key", :dnsmadeeasy_secret_key => "secret"}
    runner.node.set[:dns][:disable] = false
    runner.converge(described_recipe)
  end

  it 'installs entry in dnsmadeeasy v2.0' do
    expect(chef_run).to create_dns('DME Node DNS entry')
  end

end
