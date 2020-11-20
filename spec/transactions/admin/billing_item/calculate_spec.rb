describe Transactions::Admin::BillingItem::Calculate do
  before(:each) do
    Import.global('services.redis_cache').flushall
  end

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 0o1, 0o1))
  end

  let(:admin) { create(:account, :buzzn_operator) }
  let(:localpool) { create(:group, :localpool) }
  let(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
  let(:billing) do
    billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
    billing_cycle.billings << billing
    billing
  end
  let!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first,
           begin_date: billing.begin_date,
           end_date: billing.begin_date.next_month(6),
           vat: vat)
  end

  let!(:billing_item2) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first,
           begin_date: billing.begin_date.next_month(6),
           end_date: billing.end_date,
           vat: vat)
  end

  let(:billing_item_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts.retrieve(billing.contract.id).billings.first.items.retrieve(billing_item.id) }
  let(:billing_item_resource2) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts.retrieve(billing.contract.id).billings.first.items.retrieve(billing_item2.id) }

  let(:params) do
    {
      end_date: billing_item.end_date,
      begin_date: billing_item.begin_date,
      updated_at: billing_item.updated_at.to_json
    }
  end

  let(:result) do
    Transactions::Admin::BillingItem::Calculate.new.(resource: billing_item_resource,
                                                     params: params)
  end

  context 'without a billing begin reading and end reading' do
    it 'does not create' do
      expect {result}.to raise_error(Buzzn::ValidationError, '{:reading=>["billing must have a begin and end reading"]}')
    end

  end

  context 'with a billing begin reading and end reading' do
    let!(:billing_begin_reading) do
      create(:reading, :regular, raw_value: 100, register: billing.contract.register_meta.registers.first, date: billing.begin_date)
    end

    let!(:billing_end_reading) do
      create(:reading, :regular, raw_value: 200, register: billing.contract.register_meta.registers.first, date: billing.end_date)
    end

    it 'creates' do
      expect(result).to be_success
      expect(billing_item_resource.begin_reading.raw_value).to eql 100
      expect(billing_item_resource.end_reading.raw_value).to eql 149
      expect(billing_item_resource2.begin_reading.raw_value).to eql 149
      expect(billing_item_resource2.end_reading.raw_value).to eql 200
    end

  end

end
