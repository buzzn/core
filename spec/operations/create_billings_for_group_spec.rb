describe Operations::CreateBillingsForGroup do

  class Stub

    def initialize(result)
      @result = result
    end

    def call(_args)
      @result
    end

  end

  let(:billing_item)  { build(:billing_item, date_range: date_range) }
  let(:factory) do
    result = [{
      market_location: 'Market location 1',
      contracts: [
        {
          contract: contract,
          items: [billing_item]
        }
      ]
    }]
    Stub.new(result)
  end
  let(:date_range)    { Date.new(2017, 1, 1)...Date.new(2018, 1, 1) }
  let(:billing_cycle) { create(:billing_cycle, date_range: date_range) }
  let(:contract)      { create(:contract, :localpool_powertaker) }
  let(:group)         { create(:localpool) }
  let(:op)            { Operations::CreateBillingsForGroup.new(factory: factory) }

  it 'works', :focus do
    expect(op.call({ billing_cycle: billing_cycle, date_range: date_range }, group)).to be_success
  end

  it 'creates the correct billings' do
    expect do
      op.call({ billing_cycle: billing_cycle, date_range: date_range }, group)
    end.to change(Billing, :count)
    expect(Billing.last).to have_attributes(
      status:        'open',
      date_range:    billing_cycle.date_range,
      billing_cycle: billing_cycle,
      contract:      contract
    )
    expect(Billing.last.items.first.date_range).to eq(billing_item.date_range)
  end
end