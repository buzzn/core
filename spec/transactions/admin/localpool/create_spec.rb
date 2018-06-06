require 'buzzn/transactions/admin/localpool/create'

describe Transactions::Admin::Localpool::Create do

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator) }

  entity(:transaction) { Transactions::Admin::Localpool::Create.new }

  context 'without address' do

    entity(:result) do
      transaction.(params: {name: 'takari'}, resource: resource).value
    end

    it { expect(result.address).to be nil }
    it { expect(result).to be_a Admin::LocalpoolResource }

  end

  context 'with address' do

    entity(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'} }

    entity(:result) do
      transaction.(params: {name: 'akari', address: address},
                   resource: resource).value
    end

    it { expect(result).to be_a Admin::LocalpoolResource }
    it { expect(result.address).to be_a AddressResource }

  end
end
