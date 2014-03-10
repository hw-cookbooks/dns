require 'spec_helper'

describe "DNSMadeEasy DNS provider" do

  let(:provider) do
    provider = Chef::Provider::Dnsmadeeasy.new(new_resource, run_context)
    provider.stub(:create).and_return(client_stub)
    provider
  end

end
