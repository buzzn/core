require 'buzzn/transactions/base'

describe Transactions::StepAdapters::Validate do

  class ValidateTransaction < Transactions::Base

    validate :params_schema

    def params_schema
      Schemas::Constraints::Group
    end
  end

  subject { ValidateTransaction.new }

  it { expect(subject.call(params: {name: 'my castle'})).to be_success }

  it 'pass input through coersed' do
    expect(subject.call(params: {name: 'my castle', start_date: '01.01.2017'}).value).to eq(params: {name: 'my castle', start_date: Date.new(2017, 1, 1)})
  end

  it do
    expect { subject.call(params:{}) }.to raise_error(Buzzn::ValidationError)
  end

end
