# coding: utf-8
describe BillingCycleResource do

  let(:localpool) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  let(:billing_cycle) { Fabricate(:billing_cycle,
                                  localpool: localpool,
                                  begin_date: Date.new(2016, 8, 4),
                                  end_date: Date.new(2016, 12, 31)) }
  let(:billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.by_label(Register::Base::CONSUMPTION).first.contracts.localpool_power_takers.first) }
  let(:other_billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: localpool.registers.by_label(Register::Base::CONSUMPTION)[1].contracts.localpool_power_takers.first) }

  let :manager do
    user = Fabricate(:user)
    user.add_role(:manager, localpool)
    user
  end

  let(:base_attributes) { [:name,
                           :begin_date,
                           :end_date ] }

  it 'retrieve' do
    json = BillingCycleResource.retrieve(manager, billing_cycle.id).to_h
    expect(json.keys & base_attributes).to match_array base_attributes
  end

  it 'gets all billings from billing_cycle' do
    billings = [billing, other_billing]
    json = BillingCycleResource.retrieve(manager, billing_cycle.id).billings.sort!{|a, b| a.object.id <=> b.object.id}
    expect(json.first.is_a?(BillingResource)).to eq true
    expect(json.size).to eq 2
    expect([json[0].object, json[1].object]).to eq billings.sort!{|a, b| a.id <=> b.id}
  end

  class Broker::Discovergy
    def validates_credentials
    end
  end

  class Buzzn::Discovergy::DataSource
    def aggregated(register, mode, interval)
      result = Buzzn::DataResultSet.send(:milliwatt_hour, 'u-i-d')
      result.add(Time.new(interval.from), 666666666666, register.direction.to_sym)
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
    expect(json.size).to eq 16
  end
end

