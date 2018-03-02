module SampleData::ContractFactory

  class << self

    def create(attrs = {})
      contract = create_contract(attrs.except(:register_readings, :register))
      link_register(contract, attrs[:register])
      create_register_readings(contract, attrs[:register_readings])
      create_roles(contract)
      contract
    end

    private

    def create_contract(attrs)
      all_attrs = attrs.merge(localpool: localpool).reverse_merge(tariffs: tariffs)
      if all_attrs.delete(:gap_contract)
        contract = FactoryGirl.create(:contract, :localpool_gap, all_attrs)
        contract.localpool.update(gap_contract_customer: contract.customer)
        contract
      elsif attrs.key?(:customer)
        all_attrs.reverse_merge!(contractor: localpool.owner)
        FactoryGirl.create(:contract, :localpool_powertaker, all_attrs)
      else
        FactoryGirl.create(:contract, :localpool_third_party, all_attrs)
      end
    end

    def link_register(contract, register)
      contract.market_location.register = register if register
    end

    def create_register_readings(contract, register_readings)
      return if register_readings.blank? # blank? works for both nil and []
      contract.market_location.register.readings = register_readings
    end

    def create_roles(contract)
      person =
        if contract.customer.is_a?(Person)
          contract.customer
        elsif contract.customer.is_a?(Organization)
          contract.customer.contact
        end
      if person
        person.add_role(Role::GROUP_MEMBER, localpool)
        person.add_role(Role::CONTRACT, contract)
      end
    end

    def localpool
      SampleData.localpools.people_power
    end

    def tariffs
      SampleData.localpools.people_power.tariffs.where(name: 'Hausstrom - Standard')
    end

  end

end

SampleData.contracts = OpenStruct.new

# FIXME: when https://goo.gl/6pzpFd is implemented, assign the grid in/out registers correctly
SampleData.contracts.mpo = create(:contract, :metering_point_operator,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')]
                                 )

SampleData.contracts.lpp = create(:contract, :localpool_processing,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')],
  tariffs: [
    build(:tariff, name: 'Standard', energyprice_cents_per_kwh: 28.9, group: SampleData.localpools.people_power),
    build(:tariff, name: 'Reduziert', energyprice_cents_per_kwh: 25.9, group: SampleData.localpools.people_power)
  ]
                                 )

SampleData.contracts.pt1 = SampleData::ContractFactory.create(
  customer: SampleData.persons.pt1,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.wohnung_1
)

SampleData.contracts.pt2 = SampleData::ContractFactory.create(
  customer: SampleData.persons.pt2,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.wohnung_2
)

# terminated gap contract
SampleData.contracts.pt3gap = SampleData::ContractFactory.create(
  gap_contract: true,
  signing_date: SampleData.localpools.people_power.start_date - 25.days,
  begin_date: SampleData.localpools.people_power.start_date,
  termination_date: Date.today,
  end_date: Date.today + 1.month,
  contractor: SampleData.localpools.people_power.owner,
  customer: Organization.find_by(slug: 'hv-schneider'),
  market_location: SampleData.market_locations.wohnung_3
)

SampleData.contracts.pt3 = SampleData::ContractFactory.create(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  customer: SampleData.persons.pt3,
  register_readings: [
    build(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.wohnung_3
)
SampleData.contracts.pt3.customer.add_role(Role::GROUP_ENERGY_MENTOR, SampleData.contracts.pt3.localpool)

SampleData.contracts.pt4 = SampleData::ContractFactory.create(
  signing_date: Date.parse('2017-1-10'),
  begin_date: Date.parse('2017-2-1'),
  termination_date: Date.yesterday,
  end_date: Date.today + 1.month,
  customer: SampleData.persons.pt4,
  register_readings: [
    build(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  payments: [
   build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
  market_location: SampleData.market_locations.wohnung_4
)

# beendet, Auszug
SampleData.contracts.pt5a = SampleData::ContractFactory.create(
  termination_date: Date.parse('2017-3-10'),
  end_date: Date.parse('2017-4-1'),
  customer: SampleData.persons.pt5a,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000, register: nil),
    build(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000, register: nil)
  ],
  market_location: SampleData.market_locations.wohnung_5,
  payments: [
    build(:payment, price_cents: 45_00, begin_date: '2016-01-01', cycle: 'monthly')
  ],
)

# Leerstand
SampleData.contracts.pt5_empty = SampleData::ContractFactory.create(
  gap_contract: true,
  signing_date: SampleData.contracts.pt5a.termination_date,
  begin_date: SampleData.contracts.pt5a.end_date,
  termination_date: Date.parse('2017-4-30'),
  end_date: Date.parse('2017-5-1'),
  # TODO: this should later be removed
  register: SampleData.contracts.pt5a.market_location.register, # important !
  contractor: SampleData.localpools.people_power.owner,
  customer: Organization.find_by(slug: 'hv-schneider'),
  market_location: SampleData.market_locations.wohnung_5
)

# zieht ein
SampleData.contracts.pt5b = SampleData::ContractFactory.create(
  signing_date: Date.parse('2017-4-10'),
  begin_date: Date.parse('2017-5-1'),
  # TODO: this should later be removed
  register: SampleData.contracts.pt5a.market_location.register, # important !
  customer: SampleData.persons.pt5b,
  market_location: SampleData.market_locations.wohnung_5
)

# Drittlieferant
SampleData.contracts.pt6 = SampleData::ContractFactory.create(
  market_location: SampleData.market_locations.wohnung_6
)

# Drittlieferant, vor Wechsel zu people power
SampleData.contracts.pt7a = SampleData::ContractFactory.create(
  termination_date: Date.parse('2017-2-15'),
  end_date: Date.parse('2017-3-1'),
  market_location: SampleData.market_locations.wohnung_7
)

# Drittlieferant, nach Wechsel zu people power
SampleData.contracts.pt7b = SampleData::ContractFactory.create(
  signing_date: SampleData.contracts.pt7a.termination_date,
  begin_date: SampleData.contracts.pt7a.end_date,
  customer: SampleData.persons.pt7,
  # TODO: this should later be removed
  register: SampleData.contracts.pt7a.market_location.register, # important !
  market_location: SampleData.market_locations.wohnung_7
)

# English language speaker
SampleData.contracts.pt8 = SampleData::ContractFactory.create(
  customer: SampleData.persons.pt8,
  market_location: SampleData.market_locations.wohnung_8
)

# Two more powertakers to make them 10 ...
SampleData.contracts.pt9 = SampleData::ContractFactory.create(
  customer: SampleData.persons.pt9,
  market_location: SampleData.market_locations.wohnung_9
)
# a substitute meter/register
SampleData.contracts.pt10 = SampleData::ContractFactory.create(
  customer: SampleData.persons.pt10,
  register: FactoryGirl.create(:register, :substitute,
    meter: build(:meter, :virtual, group: SampleData.localpools.people_power)),
  market_location: SampleData.market_locations.wohnung_10
)

# Allgemeinstrom (Hausbeleuchtung etc.)
SampleData.contracts.common_consumption = SampleData::ContractFactory.create(
  contractor: SampleData.localpools.people_power.owner,
  customer: SampleData.localpools.people_power.owner,
  register: create(:register, :consumption_common,
    meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)
                  ),
  market_location: SampleData.market_locations.common_consumption
)
