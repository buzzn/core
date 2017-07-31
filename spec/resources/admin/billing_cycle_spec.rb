# coding: utf-8
describe Admin::BillingCycleResource do

  entity(:localpool) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  entity(:billing_cycle) { Fabricate(:billing_cycle,
                                  localpool: localpool,
                                  begin_date: Date.new(2016, 8, 4),
                                  end_date: Date.new(2016, 12, 31)) }
  entity!(:other_billing_cycle) { Fabricate(:billing_cycle,
                                  localpool: localpool,
                                  begin_date: Date.new(2015, 8, 4),
                                  end_date: Date.new(2015, 12, 31)) }
  entity!(:billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.consumption.first.contracts.localpool_power_takers.first) }
  entity(:other_billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.by_label(Register::Base::CONSUMPTION)[1].contracts.localpool_power_takers.first) }

  entity(:admin) { Fabricate(:admin) }

  entity(:base_attributes) { [ 'id', 'type', 'updated_at',
                               'name',
                               'begin_date',
                               'end_date' ] }

  let(:billing_cycles) do
    Admin::LocalpoolResource.all(admin).retrieve(localpool.id).billing_cycles
  end

  it 'retrieve' do
    result = billing_cycles.retrieve(billing_cycle.id).to_h
    expect(result.keys).to match_array base_attributes
  end

  it 'gets all billings from billing_cycle' do
    result = billing_cycles.retrieve(billing_cycle.id).billings
    expect(result.first.is_a?(Admin::BillingResource)).to eq true
    expect(result.size).to eq billing_cycle.billings.size
    expect(result.collect{|b| b.object}).to match_array billing_cycle.billings
    billing.destroy
  end

  it 'creates all regular billings' do
    begin
      expected = []
      3.times do |i|
        expected << Fabricate(:billing,
                              billing_cycle: billing_cycle,
                              localpool_power_taker_contract: localpool.registers.consumption[i].contracts.localpool_power_takers.first)
      end
      BillingCycle.billings(expected)

      result = billing_cycles.retrieve(billing_cycle.id).create_regular_billings(accounting_year: 2016)
      expect(result.first.is_a?(Admin::BillingResource)).to eq true
      expect(result.size).to eq 3
    ensure
      BillingCycle.billings(nil)
    end
  end

  it 'deletes a billing cycle' do
    size = BillingCycle.all.size
    billing_cycles.retrieve(other_billing_cycle.id).delete
    expect(BillingCycle.all.size).to eq size - 1
  end
end

