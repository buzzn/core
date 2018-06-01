require 'buzzn/transactions/base'

describe Transactions::StepAdapters::Precondition do

  class PreconditionTransaction < Transactions::Base

    precondition :create_precondition_schema

    def create_precondition_schema
      Schemas::Constraints::Group
    end
  end

  entity(:localpool) { create(:group, :localpool) }
  entity(:resource) { Admin::LocalpoolResource.new(localpool) }

  subject { PreconditionTransaction.new }

  it do
    localpool.name = 'my castle'
    expect(subject.call(resource: resource)).to be_success
  end

  it do
    localpool.name = nil
    expect { subject.call(resource: resource) }.to raise_error(Buzzn::ValidationError)
  end

end
