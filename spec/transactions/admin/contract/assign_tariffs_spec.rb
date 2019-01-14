describe Transactions::Admin::Contract::Localpool::AssignTariffs , order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:person) do
    create(:person, :with_bank_account)
  end

  let(:today) do
    Date.today
  end

  let(:contract) do
    lpc
    create(:contract, :localpool_powertaker,
           begin_date: today,
           signing_date: today,
           customer: person,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    contract.reload
    localpool.reload
    localpoolr.localpool_power_taker_contracts.first
  end

  # Tariff configuration
  # t1 xxxxx
  # t2     xxx
  # t3       xxxxxxxx
  # t4 xxxxx

  let!(:tariff_1) do
    create(:tariff, group: localpool, begin_date: today)
  end

  let!(:tariff_2) do
    create(:tariff, group: localpool, begin_date: today+30)
  end

  let!(:tariff_3) do
    create(:tariff, group: localpool, begin_date: today+32)
  end

  let!(:tariff_4) do
    create(:tariff, group: localpool, begin_date: today)
  end

  context 'with a valid tariff combination' do

    let(:params) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_1.id, tariff_2.id]
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params,
                                                                   resource: resource)
    end

    it 'assigns' do
      expect(result).to be_success
      contract.reload
      expect(contract.tariffs.pluck(:id)).to eql [tariff_1.id, tariff_2.id]
    end

  end

  context 'with an invalid tariff' do
    let(:params) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [1232134213, 3123212455]
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params,
                                                                   resource: resource)
    end

    it 'assigns' do
      expect {result}.to raise_error(Buzzn::ValidationError, '{:tariffs=>["one or more tariffs do not exist"]}')
    end

  end

  context 'with an already present BillingItem' do
    let(:params_one) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_1.id, tariff_2.id]
      }
    end

    let(:params_two) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_4.id, tariff_2.id]
      }
    end

    let(:result_first) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params_one,
                                                                   resource: resource)
    end

    let(:result_second) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params_two,
                                                                   resource: resource)
    end

    it 'does not remove tariff_1 from the contract' do
      expect(result_first).to be_success
      billing = create(:billing, contract: contract)
      billing_item = create(:billing_item, billing: billing, tariff: tariff_1)
      resource.object.reload
      expect {result_second}.to raise_error(Buzzn::ValidationError, '{:tariffs=>["tariffs are already used in billings"]}')
    end

  end

  context 'with overlapping tariffs' do
    let(:params_one) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_1.id, tariff_2.id]
      }
    end

    # tariff1 and tariff4 overlaps, so tariff4 would also be active
    # for the already created billing item
    let(:params_two) do
      {
        updated_at: resource.updated_at.to_json,
        tariff_ids: [tariff_1.id, tariff_2.id, tariff_4.id]
      }
    end

    let(:result_first) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params_one,
                                                                   resource: resource)
    end

    let(:result_second) do
      Transactions::Admin::Contract::Localpool::AssignTariffs.new.(params: params_two,
                                                                   resource: resource)
    end

    it 'does not assign tariff_4 to the contract' do
      expect(result_first).to be_success
      billing = create(:billing, contract: contract)
      billing_item = create(:billing_item, billing: billing, tariff: tariff_1)
      resource.object.reload
      expect {result_second}.to raise_error(Buzzn::ValidationError, {:tariffs=>["tariff id #{tariff_4.id} is active for an already present billing item"]}.to_s)
    end

  end

end
