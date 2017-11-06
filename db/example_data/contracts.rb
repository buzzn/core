def localpool_contract(attrs = {})
  localpool = SampleData.localpools.people_power
  factory_attributes = attrs.except(:register_readings).merge(localpool: localpool).reverse_merge(contractor: localpool.owner)
  contract = create(:contract, :localpool_powertaker, factory_attributes)
  contract.register.readings = attrs[:register_readings] unless attrs.fetch(:register_readings, []).empty?
  if contract.customer.is_a?(Person) # TODO: clarify what to do when it's an Organization?
    contract.customer.add_role(Role::GROUP_MEMBER, localpool)
    contract.customer.add_role(Role::CONTRACT, contract)
  end
  contract
end

SampleData.contracts = OpenStruct.new

# FIXME: when https://goo.gl/6pzpFd is implemented, assign the grid in/out registers correctly
SampleData.contracts.mpo = create(:contract, :metering_point_operator,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [ build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly') ]
)

SampleData.contracts.lpp = create(:contract, :localpool_processing,
  localpool: SampleData.localpools.people_power,
  customer: SampleData.localpools.people_power.owner,
  contractor: Organization.buzzn,
  payments: [ build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly') ],
  tariffs: [
    build(:tariff, name: "Regular", energyprice_cents_per_kwh: 28.9, contracts: nil),
    build(:tariff, name: "Reduced", energyprice_cents_per_kwh: 25.9, contracts: nil)
  ]
)

SampleData.contracts.pt1 = localpool_contract(
  customer: SampleData.persons.pt1,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

SampleData.contracts.pt2 = localpool_contract(
  customer: SampleData.persons.pt2,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

SampleData.contracts.pt3 = localpool_contract(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  customer: SampleData.persons.pt3,
  register_readings: [
    build(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

SampleData.contracts.pt4 = localpool_contract(
  signing_date: Date.parse("2017-1-10"),
  begin_date: Date.parse("2017-2-1"),
  termination_date: Date.yesterday,
  end_date: Date.today + 1.month,
  customer: SampleData.persons.pt4,
  register_readings: [
    build(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  payments: [
   build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

# beendet, Auszug
SampleData.contracts.pt5a = localpool_contract(
  termination_date: Date.parse("2017-3-10"),
  end_date: Date.parse("2017-4-1"),
  customer: SampleData.persons.pt5a,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000, register: nil),
    build(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 45_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

# Leerstand
SampleData.contracts.pt5_empty = localpool_contract(
  signing_date: SampleData.contracts.pt5a.termination_date,
  begin_date: SampleData.contracts.pt5a.end_date,
  termination_date: Date.parse("2017-4-30"),
  end_date: Date.parse("2017-5-1"),
  register: SampleData.contracts.pt5a.register, # important !
  customer: Organization.find_by(slug: 'hv-schneider'),
)

# zieht ein
SampleData.contracts.pt5b = localpool_contract(
  signing_date: Date.parse("2017-4-10"),
  begin_date: Date.parse("2017-5-1"),
  register: SampleData.contracts.pt5a.register, # important !
  customer: SampleData.persons.pt5b,
)

# Drittlieferant
SampleData.contracts.pt6 = localpool_contract(
  contractor: Organization.find_by(slug: '3rd-party'),
  customer: SampleData.persons.pt6
)

# Drittlieferant, vor Wechsel zu people power
SampleData.contracts.pt7a = localpool_contract(
  termination_date: Date.parse("2017-2-15"),
  end_date: Date.parse("2017-3-1"),
  contractor: Organization.find_by(slug: '3rd-party'),
  customer: SampleData.persons.pt7,
)
SampleData.contracts.pt7a.customer.add_role(Role::GROUP_ENERGY_MENTOR, SampleData.contracts.pt7a.localpool)


# Drittlieferant, nach Wechsel zu people power
SampleData.contracts.pt7b = localpool_contract(
  signing_date: SampleData.contracts.pt7a.termination_date,
  begin_date: SampleData.contracts.pt7a.end_date,
  customer: SampleData.persons.pt7,
  register: SampleData.contracts.pt7a.register, # important !
)

# English
SampleData.contracts.pt8 = localpool_contract(customer: SampleData.persons.pt8)

# Two more powertakers to make them 10 ...
SampleData.contracts.pt9 = localpool_contract(customer: SampleData.persons.pt9)
SampleData.contracts.pt10 = localpool_contract(customer: SampleData.persons.pt10)

# Allgemeinstrom (Hausbeleuchtung etc.)
SampleData.contracts.common_consumption = localpool_contract(
  contractor: SampleData.localpools.people_power.owner,
  customer: SampleData.localpools.people_power.owner,
  register: create(:register, :input, name: "Allgemeinstrom", group: SampleData.localpools.people_power),
)
