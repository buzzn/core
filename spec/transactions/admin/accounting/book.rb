
describe Transactions::Admin::Accounting::Book do

  let(:service) { Services::Accounting.new }
  let(:localpool) { create(:group, :localpool) }
  let(:contract) do
    create(:contract, :localpool_powertaker,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:operator) { create(:account, :buzzn_operator) }

  let!(:accounting_entriesr) do
    localpoolr.contracts.retrieve(contract.id).balance_sheet.entries
  end

  context 'valid data' do
    let(:params) do
      {
        amount: 1337,
        comment: 'bribe'
      }
    end

    let(:result) do
      Transactions::Admin::Accounting::Book.new.(resource: accounting_entriesr,
                                                 params: params)
    end

    it 'books' do
      expect(result).to be_success
      value = result.value!
      expect(value).to be_a Accounting::EntryResource
      expect(value.amount).to eql 1337
    end

  end

end
