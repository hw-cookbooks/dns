require 'spec_helper'
require 'fog'

describe 'Run dns::default' do

  let(:chef_run) do
    runner = ChefSpec::Runner.new(step_into: ['dns'])
    runner.node.set[:dns][:provider] = "AWS"
    runner.node.set[:dns][:credentials] = {:aws_access_key_id => "MOCK_ACCESS_KEY", :aws_secret_access_key => "MOCK_SECRET_KEY"}
    runner.node.set[:dns][:disable] = false
    runner.node.set[:dns][:domain] = "test.com"
    runner.node.set[:dns][:entry][:name] = "www"
    runner.node.set[:dns][:entry][:value] = "10.0.0.1"
    runner.node.set[:dns][:entry][:type] = "A"
    runner.node.set[:dns][:entry][:ttl] = 60
    runner.converge("fake::fog_mock", "fake::zone", "dns::default")
  end

  it "check if dns entry was created" do
    chef_run

    Fog.mock!
    dns = Fog::DNS.new({
      :provider     => 'AWS',
      :aws_access_key_id => "MOCK_ACCESS_KEY",
      :aws_secret_access_key => "MOCK_SECRET_KEY"
    })

    zone = dns.zones.detect do |z|
      z.domain == "test.com."
    end or raise "zone not created"

    record = zone.records.detect do |r|
      r.name == "www"
    end or raise "record not created"

  end
end

