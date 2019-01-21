describe Transactions::Admin::Billing::Create do

  # common for all cases
  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:person) do
    create(:person, :with_bank_account)
  end

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  # special cases

  context 'case 1', order: :defined do
    let(:contract_begin) { Date.new(2019, 1, 16) }
    let(:tariff1_begin)  { Date.new(2019, 1, 1)  }
    let(:tariff2_begin)  { Date.new(2019, 3, 1)  }
    let(:billing1_begin) { Date.new(2019, 1, 18) }
    let(:billing1_end)   { Date.new(2019, 3, 25) }
    let(:billing2_begin) { Date.new(2019, 1, 16) }
    let(:billing2_end)   { Date.new(2019, 4, 15) }

    let(:tariff1) { create(:tariff, group: localpool, begin_date: tariff1_begin) }
    let(:tariff2) { create(:tariff, group: localpool, begin_date: tariff2_begin) }

    let(:meter) do
      create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
    end

    let(:contract) do
      create(:contract, :localpool_powertaker,
             customer: person,
             begin_date: contract_begin,
             register_meta: meter.registers.first.meta,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let!(:billingsr) do
      localpoolr.contracts.retrieve(contract.id).billings
    end

    before do
      contract.tariffs << tariff1 << tariff2
      contract.save
      contract.reload
    end

    let(:params_billing_1) do
      {
        :begin_date => billing1_begin,
        :last_date  => billing1_end
      }
    end

    let(:params_billing_2) do
      {
        :begin_date => billing2_begin,
        :last_date  => billing2_end
      }
    end

    let(:result_billing_1) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_1,
                                                parent: contract)
    end

    let(:result_billing_2) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_2,
                                                parent: contract)
    end

    it 'creates two correct billings' do
      expect(result_billing_1).to be_success
      value = result_billing_1.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 2
      item_a = object.items[0]
      item_b = object.items[1]
      expect(item_a.begin_date).to eql billing1_begin
      expect(item_a.end_date).to   eql tariff2_begin
      expect(item_b.begin_date).to eql tariff2_begin
      expect(item_b.end_date).to   eql billing1_end + 1.day # last_date!
      expect(meter.registers.count).to eql 1
      expect(meter.registers.first.billing_items.count).to eql 2

      contract.reload
      # fetch first billing
      first_billing = object

      expect(result_billing_2).to be_success
      value = result_billing_2.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 2
      item_a = object.items[0]
      item_b = object.items[1]
      expect(item_a.begin_date).to eql billing2_begin
      expect(item_a.end_date).to   eql first_billing.items[0].begin_date
      expect(item_b.begin_date).to eql first_billing.items[1].end_date
      expect(item_b.end_date).to   eql billing2_end + 1 # last_date!
      expect(meter.registers.count).to eql 1
      expect(meter.registers.first.billing_items.count).to eql 4
    end

  end

  context 'case 2', order: :defined do
    let(:contract_begin) { Date.new(2019, 1, 16) }
    let(:tariff1_begin)  { Date.new(2019, 1, 1)  }
    let(:tariff2_begin)  { Date.new(2019, 3, 1)  }

    let(:billing1_begin) { Date.new(2019, 1, 16) }
    let(:billing1_end)   { tariff2_begin - 1.day }
    # ^ end_date will be tariff2_begin, thus billing1.end_date == billing2.begin_date
    let(:billing2_begin) { tariff2_begin }
    let(:billing2_end)   { Date.new(2019, 4, 15) }

    let(:tariff1) { create(:tariff, group: localpool, begin_date: tariff1_begin) }
    let(:tariff2) { create(:tariff, group: localpool, begin_date: tariff2_begin) }
    let(:meter) do
      create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
    end

    let(:contract) do
      create(:contract, :localpool_powertaker,
             customer: person,
             begin_date: contract_begin,
             register_meta: meter.registers.first.meta,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let!(:billingsr) do
      localpoolr.contracts.retrieve(contract.id).billings
    end

    before do
      contract.tariffs << tariff1 << tariff2
      contract.save
      contract.reload
    end

    let(:params_billing_1) do
      {
        :begin_date => billing1_begin,
        :last_date  => billing1_end
      }
    end

    let(:params_billing_2) do
      {
        :begin_date => billing2_begin,
        :last_date  => billing2_end
      }
    end

    let(:result_billing_1) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_1,
                                                parent: contract)
    end

    let(:result_billing_2) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_2,
                                                parent: contract)
    end

    it 'creates two correct billings' do
      expect(result_billing_1).to be_success
      value = result_billing_1.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 1
      item_a = object.items[0]
      expect(item_a.begin_date).to eql billing1_begin
      expect(item_a.end_date).to   eql tariff2_begin
      expect(meter.registers.count).to eql 1
      expect(meter.registers.first.billing_items.count).to eql 1

      contract.reload
      # fetch first billing
      first_billing = object
      expect(result_billing_2).to be_success
      value = result_billing_2.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 1
      item_a = object.items[0]
      expect(item_a.begin_date).to eql billing2_begin
      expect(item_a.end_date).to   eql billing2_end + 1.day # last_date!
      expect(meter.registers.first.billing_items.count).to eql 2
    end

  end

  context 'case 2.2', order: :defined do
    let(:contract_begin) { Date.new(2019, 1, 16) }
    let(:tariff1_begin)  { Date.new(2019, 1, 1)  }
    let(:tariff2_begin)  { Date.new(2019, 3, 1)  }

    let(:billing1_begin) { Date.new(2019, 1, 16) }
    let(:billing1_end)   { tariff2_begin }
    let(:billing2_begin) { tariff2_begin + 2.days }
    let(:billing2_end)   { Date.new(2019, 4, 15) }

    let(:tariff1) { create(:tariff, group: localpool, begin_date: tariff1_begin) }
    let(:tariff2) { create(:tariff, group: localpool, begin_date: tariff2_begin) }
    let(:meter) do
      create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
    end

    let(:contract) do
      create(:contract, :localpool_powertaker,
             customer: person,
             begin_date: contract_begin,
             register_meta: meter.registers.first.meta,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let!(:billingsr) do
      localpoolr.contracts.retrieve(contract.id).billings
    end

    before do
      contract.tariffs << tariff1 << tariff2
      contract.save
      contract.reload
    end

    let(:params_billing_1) do
      {
        :begin_date => billing1_begin,
        :last_date  => billing1_end
      }
    end

    let(:params_billing_2) do
      {
        :begin_date => billing2_begin,
        :last_date  => billing2_end
      }
    end

    let(:result_billing_1) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_1,
                                                parent: contract)
    end

    let(:result_billing_2) do
      Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                                params: params_billing_2,
                                                parent: contract)
    end

    it 'creates two correct billings' do
      expect(result_billing_1).to be_success
      value = result_billing_1.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 2
      item_a = object.items[0]
      item_b = object.items[1]
      expect(item_a.begin_date).to eql billing1_begin
      expect(item_a.end_date).to   eql tariff2_begin
      expect(item_b.begin_date).to eql tariff2_begin
      expect(item_b.end_date).to   eql billing1_end + 1.day # last_date!
      expect(meter.registers.count).to eql 1
      expect(meter.registers.first.billing_items.count).to eql 2

      contract.reload
      # fetch first billing
      first_billing = object
      expect(result_billing_2).to be_success
      value = result_billing_2.value!
      expect(value).to be_a Admin::BillingResource
      object = value.object
      expect(object.items.count).to eql 1
      item_a = object.items[0]
      expect(item_a.begin_date).to eql billing2_begin
      expect(item_a.end_date).to   eql billing2_end + 1.day # last_date!
      expect(meter.registers.first.billing_items.count).to eql 3
    end

  end

end
