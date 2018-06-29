require 'buzzn/transactions/base'

describe Transactions::StepAdapters::Authorize do

  class AuthorizeTransaction < Transactions::Base

    authorize :create_localpool

    def create_localpool(permission_context:)
      permission_context.localpools.create
    end

  end

  subject { AuthorizeTransaction.new }

  entity!(:localpool) { create(:group, :localpool) }

  entity(:admin) { create(:account, :buzzn_operator) }

  entity(:resource) { AdminResource.new(admin) }

  it { expect(subject.call(resource: resource)).to be_success }

  it 'pass input through' do
    expect(subject.call(resource: resource).value!).to eq(resource: resource)
  end

  it do
    expect { subject.call(resource: AdminResource.new(nil)) }.to raise_error(Buzzn::PermissionDenied)
  end

  it 'error message' do
    begin
      subject.call(resource: AdminResource.new(nil))
      raise 'failed'
    rescue Buzzn::PermissionDenied => e
      expect(e.message).to eq('create_localpool AdminResource: permission denied for User: --anonymous--')
    end
  end
end
