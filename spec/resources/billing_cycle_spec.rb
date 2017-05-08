# coding: utf-8
describe BillingCycleResource do

  entity(:localpool) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  entity(:billing_cycle) { Fabricate(:billing_cycle,
                                  localpool: localpool,
                                  begin_date: Date.new(2016, 8, 4),
                                  end_date: Date.new(2016, 12, 31)) }
  entity(:other_billing_cycle) { Fabricate(:billing_cycle,
                                  localpool: localpool,
                                  begin_date: Date.new(2015, 8, 4),
                                  end_date: Date.new(2015, 12, 31)) }
  entity(:billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.by_label(Register::Base::CONSUMPTION).first.contracts.localpool_power_takers.first) }
  entity(:other_billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.by_label(Register::Base::CONSUMPTION)[1].contracts.localpool_power_takers.first) }

  entity :manager do
    user = Fabricate(:user)
    user.add_role(:manager, localpool)
    user
  end

  entity(:base_attributes) { [:name,
                           :begin_date,
                           :end_date ] }

  it 'retrieve' do
    json = BillingCycleResource.retrieve(manager, billing_cycle.id).to_h
    expect(json.keys & base_attributes).to match_array base_attributes
  end

  it 'gets all billings from billing_cycle' do
    json = BillingCycleResource.retrieve(manager, billing_cycle.id).billings
    expect(json.first.is_a?(BillingResource)).to eq true
    expect(json.size).to eq billing_cycle.billings.size
    expect(json.collect{|b| b.object}).to match_array billing_cycle.billings
  end

  class Broker::Discovergy
    def validates_credentials
    end
  end

  class Buzzn::Discovergy::DataSource
    def aggregated(register, mode, interval)
      result = Buzzn::DataResultSet.send(:milliwatt_hour, 'u-i-d')
      result.add(Time.at(interval.from), 666666666666, register.direction.to_sym)
      result
    end
  end

  it 'creates all regular billings' do
    localpool.registers.collect(&:meter).uniq.each do |meter|
      Fabricate(:discovergy_broker,
                mode: meter.registers.size == 1 ? (meter.registers.first.input? ? :in : :out) : :in_out,
                resource: meter,
                external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
    end
    json = BillingCycleResource.retrieve(manager, billing_cycle.id).create_regular_billings({accounting_year: 2016})
    expect(json.first.is_a?(BillingResource)).to eq true
    expect(json.size).to eq 8
  end

  it 'deletes a billing cycle' do
    other_billing_cycle
    size = BillingCycle.all.size
    BillingCycleResource.retrieve(manager, other_billing_cycle.id).delete
    expect(BillingCycle.all.size).to eq size - 1
  end
end

