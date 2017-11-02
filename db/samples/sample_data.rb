# IMPORTANT: don't require factory girl in the part that generates the SEED data.
# That data is also used for the production environments and must not contain faked data!
FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

# ActiveRecord::Base.logger = Logger.new(STDOUT)

Buzzn::Logger.root.info("seeds: loading sample data")

def localpool_contract(attrs = {})
  localpool = $localpools[:people_power]
  factory_attributes = attrs.except(:register_readings).merge(localpool: localpool).reverse_merge(contractor: localpool.owner)
  contract = create(:contract, :localpool_powertaker, factory_attributes)
  contract.register.readings = attrs[:register_readings] unless attrs.fetch(:register_readings, []).empty?
  if contract.customer.is_a?(Person) # TODO: clarify what to do when it's an Organization?
    contract.customer.add_role(Role::GROUP_MEMBER, localpool)
    contract.customer.add_role(Role::CONTRACT, contract)
  end
  contract
end

def person(attributes)
  create(:person, :with_bank_account, :with_self_role, :with_account, attributes)
end

persons = {
  operator: person(first_name: 'Philipp', last_name: 'Operator', roles: { Role::BUZZN_OPERATOR => nil }),
  group_owner: person(:wolfgang),
  brumbauer:   person(first_name: 'Traudl', last_name: 'Brumbauer', prefix: 'F',
                      roles: { Role::ORGANIZATION => Organization.find_by(slug: 'hell-warm') }
  ),
  pt1:  person(first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
  pt2:  person(first_name: 'Carla', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
  pt3:  person(first_name: 'Bernd', last_name: 'Powertaker3'),
  pt4:  person(first_name: 'Karl', last_name: 'Powertaker4'),
  pt5a: person(first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F'),
  pt5b: person(first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)'),
  pt6:  person(first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)'),
  pt7:  person(first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F'),
  pt8:  person(first_name: 'Sam',  last_name: 'Powertaker8', preferred_language: 'english'),
  pt9:  person(first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F'),
  pt10: person(first_name: 'Mohammed', last_name: 'Powertaker10'),
}

$localpools = {
   people_power: create(:localpool, :people_power, owner: persons[:group_owner],
                  admins: [ persons[:brumbauer] ],
                  # FIXME: to be renamed to group_tariff
                  prices: [
                    build(:price, name: "Hausstrom - Standard"),
                    build(:price, name: "Hausstrom - Reduziert", energyprice_cents_per_kilowatt_hour: 24.9),
                  ]
                )
}

contracts = {}

contracts[:pt1] = localpool_contract(
  customer: persons[:pt1],
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

contracts[:pt2] = localpool_contract(
  customer: persons[:pt2],
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

contracts[:pt3] = localpool_contract(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  customer: persons[:pt3],
  register_readings: [
    build(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

contracts[:pt4] = localpool_contract(
  signing_date: Date.parse("2017-1-10"),
  begin_date: Date.parse("2017-2-1"),
  termination_date: Date.yesterday,
  end_date: Date.today + 1.month,
  customer: persons[:pt4],
  register_readings: [
    build(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly')
  ]
)

# beendet, Auszug
contracts[:pt5a] = localpool_contract(
  termination_date: Date.parse("2017-3-10"),
  end_date: Date.parse("2017-4-1"),
  customer: persons[:pt5a],
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
contracts[:pt5_empty] = localpool_contract(
  signing_date: contracts[:pt5a].termination_date,
  begin_date: contracts[:pt5a].end_date,
  termination_date: Date.parse("2017-4-30"),
  end_date: Date.parse("2017-5-1"),
  register: contracts[:pt5a].register, # important !
  customer: Organization.find_by(slug: 'hv-schneider'),
)

# zieht ein
contracts[:pt5b] = localpool_contract(
  signing_date: Date.parse("2017-4-10"),
  begin_date: Date.parse("2017-5-1"),
  register: contracts[:pt5a].register, # important !
  customer: persons[:pt5b],
)

# Drittlieferant
contracts[:pt6] = localpool_contract(contractor: Organization.find_by(slug: '3rd-party'), customer: persons[:pt6])

# Drittlieferant, vor Wechsel zu people power
contracts[:pt7a] = localpool_contract(
  termination_date: Date.parse("2017-2-15"),
  end_date: Date.parse("2017-3-1"),
  contractor: Organization.find_by(slug: '3rd-party'),
  customer: persons[:pt7],
)
contracts[:pt7a].customer.add_role(Role::GROUP_ENERGY_MENTOR, contracts[:pt7a].localpool)

# Drittlieferant, nach Wechsel zu people power
contracts[:pt7b] = localpool_contract(
  signing_date: contracts[:pt7a].termination_date,
  begin_date: contracts[:pt7a].end_date,
  customer: persons[:pt7],
  register: contracts[:pt7a].register, # important !
)

# English
contracts[:pt8] = localpool_contract(customer: persons[:pt8])

# Two more powertakers to make them 10 ...
contracts[:pt9] = localpool_contract(customer: persons[:pt9])
contracts[:pt10] = localpool_contract(customer: persons[:pt10])

# Allgemeinstrom (Hausbeleuchtung etc.)
contracts[:common_consumption] = localpool_contract(
  contractor: $localpools[:people_power].owner,
  customer: $localpools[:people_power].owner,
  register: create(:register, :input, name: "Allgemeinstrom", group: $localpools[:people_power]),
)

_meters = {
  # the connection to the public grid, two-way register
  grid: create(:meter, :real, :two_way,
    group: $localpools[:people_power],
    registers: [
      create(:register, :grid_output,
        group: $localpools[:people_power],
        readings: [
          build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
          build(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000, register: nil)
        ]
      ),
      create(:register, :grid_input,
        group: $localpools[:people_power],
        readings: [
          build(:reading, :setup, date: '2016-01-01', raw_value: 2_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
          build(:reading, :regular, date: '2016-12-31', raw_value: 66_000_000, register: nil)
        ]
      )
    ]
  ),
  # Virtual registers, used for corrections or calculations
  'grid_consumption_corrected': create(:meter_virtual,
    group: $localpools[:people_power]
  ),
  'grid_feeding_corrected': create(:meter_virtual,
    group: $localpools[:people_power]
  )
}



#
# Create other contracts for peoplepower group
#
# FIXME: when https://goo.gl/6pzpFd is implemented, assign the grid in/out registers correctly
create(:contract, :metering_point_operator,
       localpool: $localpools[:people_power],
       customer: $localpools[:people_power].owner,
       contractor: Organization.buzzn,
       payments: [ build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly') ]
)
create(:contract, :localpool_processing,
       localpool: $localpools[:people_power],
       customer: $localpools[:people_power].owner,
       contractor: Organization.buzzn,
       payments: [ build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly') ],
       tariffs: [
        build(:tariff, name: "Regular", energyprice_cents_per_kwh: 28.9),
        build(:tariff, name: "Reduced", energyprice_cents_per_kwh: 25.9)
      ]
)

#
# More registers (without powertakers & contracts)
#
_registers = {
  ecar: create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other],
    group: $localpools[:people_power],
    devices: [ create(:device, :ecar, commissioning: '2017-04-10', register: nil) ]
  ),
  bhkw: create(:register, :production_bhkw,
    group: $localpools[:people_power],
    devices: [ create(:device, :bhkw, commissioning: '1995-01-01', register: nil) ]
  ),
  pv: create(:register, :production_pv,
    group: $localpools[:people_power],
    devices: [ create(:device, :pv, commissioning: '2017-04-10', register: nil) ]
  )
}
