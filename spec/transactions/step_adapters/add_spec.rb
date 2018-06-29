require 'buzzn/transactions/base'

describe Transactions::StepAdapters::Add do

  class AddTransaction < Transactions::Base

    add :be
    add :with, with: :'operations.noop'

    def be
      :happy
    end

  end

  subject { AddTransaction.new }

  it { expect(subject.call(hello: :world)).to be_success }

  it { expect(subject.call(hello: :world).value!).to eq(hello: :world, be: :happy, with: nil) }

  it { expect(subject.call.value!).to eq(be: :happy, with: nil) }

end
