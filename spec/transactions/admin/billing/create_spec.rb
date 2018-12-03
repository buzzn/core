require 'buzzn/transactions/admin/billing/create'

describe Transactions::Admin::Billing::Create do
  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:person) do
    create(:person, :with_bank_account)
  end

  let(:contract) do
    create(:contract, :localpool_powertaker, :with_tariff,
           customer: person,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let!(:billingsr) do
    localpoolr.contracts.retrieve(contract.id).billings
  end

  let(:params) do
    {
      :contract_id => contract.id,
      :begin_date => contract.begin_date,
      :end_date => contract.begin_date + 90,
    }
  end

  let(:result) do
    Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                              params: params,
                                              parent: contract)
  end

  it 'works' do
    expect(result).to be_success
  end

end
