require_relative 'import_csv'
require_relative 'seeds_repository'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

puts "seeds: loading sample data"

FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

# Call the buzzn operator once so it is generated.
SeedsRepository.persons.buzzn_operator

def localpool_contract(attrs = {})
  localpool = SeedsRepository.localpools.people_power
  factory_attributes = attrs.except(:register_readings).merge(localpool: localpool).reverse_merge(contractor: localpool.owner)
  contract = create(:contract, :localpool_powertaker, factory_attributes)
  contract.register.readings = attrs[:register_readings] unless attrs.fetch(:register_readings, []).empty?
  if contract.customer.is_a?(Person) # TODO: clarify what to do when it's an Organization?
    contract.customer.add_role(Role::GROUP_MEMBER, localpool)
    contract.customer.add_role(Role::CONTRACT, contract)
  end
  contract
end

contracts = {}

contracts[:pt1] = localpool_contract(
  customer: SeedsRepository.persons.pt1,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 55_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt2] = localpool_contract(
  customer: SeedsRepository.persons.pt2,
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt3] = localpool_contract(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  status: Contract::Base.statuses[:onboarding],
  customer: SeedsRepository.persons.pt3,
  register_readings: [
    build(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 67_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

contracts[:pt4] = localpool_contract(
  signing_date: Date.parse("2017-1-10"),
  begin_date: Date.parse("2017-2-1"),
  cancellation_date: Date.yesterday,
  end_date: Date.today + 1.month,
  status: Contract::Base.statuses[:terminated],
  customer: SeedsRepository.persons.pt4,
  register_readings: [
    build(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 53_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

# beendet, Auszug
contracts[:pt5a] = localpool_contract(
  cancellation_date: Date.parse("2017-3-10"),
  end_date: Date.parse("2017-4-1"),
  status: Contract::Base.statuses[:ended],
  customer: SeedsRepository.persons[:pt5a],
  register_readings: [
    build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    build(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000, register: nil),
    build(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000, register: nil)
  ],
  payments: [
    build(:payment, price_cents: 45_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
  ]
)

# Leerstand
contracts[:pt5_empty] = localpool_contract(
  signing_date: contracts[:pt5a].cancellation_date,
  begin_date: contracts[:pt5a].end_date,
  cancellation_date: Date.parse("2017-4-30"),
  end_date: Date.parse("2017-5-1"),
  status: Contract::Base.statuses[:ended],
  register: contracts[:pt5a].register, # important !
  customer: SeedsRepository.organizations.property_management,
)

# zieht ein
contracts[:pt5b] = localpool_contract(
  signing_date: Date.parse("2017-4-10"),
  begin_date: Date.parse("2017-5-1"),
  register: contracts[:pt5a].register, # important !
  customer: SeedsRepository.persons[:pt5b],
)

# Drittlieferant
contracts[:pt6] = localpool_contract(contractor: SeedsRepository.organizations.third_party_supplier, customer: SeedsRepository.persons.pt6)

# Drittlieferant, vor Wechsel zu people power
contracts[:pt7a] = localpool_contract(
  cancellation_date: Date.parse("2017-2-15"),
  end_date: Date.parse("2017-3-1"),
  status: Contract::Base.statuses[:ended],
  contractor: SeedsRepository.organizations.third_party_supplier,
  customer: SeedsRepository.persons.pt7,
)
contracts[:pt7a].customer.add_role(Role::GROUP_ENERGY_MENTOR, contracts[:pt7a].localpool)

# Drittlieferant, nach Wechsel zu people power
contracts[:pt7b] = localpool_contract(
  signing_date: contracts[:pt7a].cancellation_date,
  begin_date: contracts[:pt7a].end_date,
  customer: SeedsRepository.persons.pt7,
  register: contracts[:pt7a].register, # important !
)

# English
contracts[:pt8] = localpool_contract(customer: SeedsRepository.persons.pt8)

# Two more powertakers to make them 10 ...
contracts[:pt9] = localpool_contract(customer: SeedsRepository.persons.pt9)
contracts[:pt10] = localpool_contract(customer: SeedsRepository.persons.pt10)

# Allgemeinstrom (Hausbeleuchtung etc.)
contracts[:common_consumption] = localpool_contract(
  contractor: SeedsRepository.localpools.people_power.owner,
  customer: SeedsRepository.localpools.people_power.owner,
  register: create(:register, :input, name: "Allgemeinstrom", group: SeedsRepository.localpools.people_power),
)

create(:meter_real, :two_way,
  group: SeedsRepository.localpools.people_power,
  registers: [
    create(:register, :grid_output,
      group: SeedsRepository.localpools.people_power,
      readings: [
        build(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
        build(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000, register: nil)
      ]
    ),
    create(:register, :grid_input,
      group: SeedsRepository.localpools.people_power,
      readings: [
        build(:reading, :setup, date: '2016-01-01', raw_value: 2_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40', register: nil),
        build(:reading, :regular, date: '2016-12-31', raw_value: 66_000_000, register: nil)
      ]
    )
  ]
)

#
# Create other contracts for peoplepower group
#
# FIXME: contractor needs to be buzzn not generic org
create(:contract, :metering_point_operator,
       localpool: SeedsRepository.localpools.people_power,
       customer: SeedsRepository.localpools.people_power.owner,
       payments: [
         build(:payment, price_cents: 120_00, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')
       ]
)

# create(:contract, :localpool_processing,
#        localpool: SeedsRepository.localpools.people_power,
#        customer: SeedsRepository.localpools.people_power.owner
# )

#
# More registers (without powertakers & contracts)
#
registers = {}

registers[:ecar] = create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other],
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :ecar, commissioning: '2017-04-10', register: nil) ]
)

registers[:bhkw] = create(:register, :production_bhkw,
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :bhkw, commissioning: '1995-01-01', register: nil) ]
)

registers[:pv] = create(:register, :production_pv,
  group: SeedsRepository.localpools.people_power,
  devices: [ create(:device, :pv, commissioning: '2017-04-10', register: nil) ]
)


# TODO add organizations and their energy energy_classifications
# %i(buzzn germany).each { |trait| create(:energy_classification, trait) }

# TODO create MPO contract
# create(:payment, price_cents: 12000, begin_date: '2016-01-01', cycle: 'monthly', source: 'calculated')

__END__

#
# on hold, to be refactored
#
import_csv(:organizations,
           converters: {preferred_language: Converters::PreferredLanguage },
           fields: %i(name description slug image email edifactemail phone fax website mode market_place_id)
)
Organization.all.each do |organization|
  create(:bank_account, contracting_party: organization)
end
