describe Transactions::Admin::BillingItem::Update do

  entity(:admin) { create(:account, :buzzn_operator) }
  entity(:localpool) { create(:group, :localpool) }
  entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
  entity(:billing) do
    billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
    billing_cycle.billings << billing
    billing
  end
  entity!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first)

  end

  let(:billing_item_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts.retrieve(billing.contract.id).billings.first.items.first }

  let(:begin_reading) do
    create(:reading, register: billing.contract.register_meta.registers.first, date: billing.begin_date)
  end

  let(:end_reading) do
    create(:reading, register: billing.contract.register_meta.registers.first, date: billing.end_date)
  end

  let(:params) do
    {
      begin_reading_id: begin_reading.id,
      end_reading_id: end_reading.id,
      updated_at: billing_item.updated_at.to_json
    }
  end

  let(:result) do
    Transactions::Admin::BillingItem::Update.new.(resource: billing_item_resource,
                                                  params: params)
  end

  it 'updates' do
    expect(billing_item.begin_reading).to be_nil
    expect(billing_item.end_reading).to be_nil
    expect(result).to be_success
    billing_item.reload
    expect(billing_item.begin_reading_id).to eql begin_reading.id
    expect(billing_item.end_reading_id).to eql end_reading.id
  end

end
