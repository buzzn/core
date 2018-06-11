require 'buzzn/transactions/admin/localpool/update'

describe Transactions::Admin::Localpool::Update do

  entity(:operator) { create(:account, :buzzn_operator) }
  entity!(:localpool) { create(:group, :localpool) }
  entity!(:address) { localpool.address }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  entity(:transaction) { Transactions::Admin::Localpool::Update.new }

  context 'without address' do

    before do
      localpool.update(address: nil)
      resource.object.reload
    end

    #it_behaves_like 'update without address', Transactions::Admin::Localpool::Update.new, resource, name: 'takari'

    # entity(:result) do
    #   transaction.(params: {name: 'takari',
    #                         updated_at: localpool.reload.updated_at.as_json},
    #                resource: resource).value
    # end

    # it { expect(result).to be_a Admin::LocalpoolResource }
    # it { expect(result.name).to eq 'takari' }
    # it { expect(result.address).to be nil }

    # context 'create address' do

    #   entity(:result2) do
    #     transaction.(params: {
    #                    name: 'takakari',
    #                    updated_at: localpool.reload.updated_at.as_json,
    #                    address: {
    #                      street: 'wallstreet', zip: '666',
    #                      city: 'atlantis', country: 'IT',
    #                      updated_at: Date.new(0).as_json
    #                    }
    #                  },
    #                  resource: resource).value
    #   end

    #   it { expect(result2).to be_a Admin::LocalpoolResource }
    #   it { expect(result2.name).to eq 'takakari' }
    #   it { expect(result2.address).to be_a AddressResource }

    # end
  end

  context 'with address' do

    before do
      localpool.update(address: address)
      resource.object.reload
    end

    entity(:result3) do
      transaction.(params: {name: 'akari',
                            updated_at: localpool.reload.updated_at.as_json},
                   resource: resource).value
    end

    it { expect(result3).to be_a Admin::LocalpoolResource }
    it { expect(result3.name).to eq 'akari' }
    it { expect(result3.address).to be_a AddressResource }

    context 'update address' do

      entity(:result4) do
        transaction.(params: {
                       name: 'akakari',
                       updated_at: localpool.reload.updated_at.as_json,
                       address: {
                         street: 'behind the black door',
                         updated_at: localpool.address.updated_at.as_json
                       }
                     },
                     resource: resource).value
      end

      it { expect(result4).to be_a Admin::LocalpoolResource }
      it { expect(result4.name).to eq 'akakari' }
      it { expect(result4.address).to be_a AddressResource }
      it { expect(result4.address.street).to eq 'behind the black door' }

    end
  end
end
