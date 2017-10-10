require_relative 'import_csv'
require_relative 'seeds_repository'

puts "seeds: loading sample data"

FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

#
# Create persons and roles on the group
#

# buzzn operator
operator = create(:person, first_name: 'Philipp', last_name: 'Operator')
operator.add_role(Role::BUZZN_OPERATOR)

# group owner
owner = SeedsRepository.persons.wolfgang
owner.add_role(Role::GROUP_OWNER, SeedsRepository.localpools.people_power)

# Traudl Brumbauer, will be admin of several localpools
brumbauer = create(:person, first_name: 'Traudl', last_name: 'Brumbauer', prefix: 'F')
brumbauer.add_role(Role::GROUP_ADMIN, SeedsRepository.localpools.people_power) # can admin the organization

def localpool_contract(attrs = {})
  localpool = SeedsRepository.localpools.people_power
  factory_attributes = attrs.except(:readings).merge(localpool: localpool).reverse_merge(contractor: localpool.owner)
  contract = create(:contract, :localpool_powertaker, factory_attributes)
  contract.register.readings = attrs[:readings] unless attrs.fetch(:readings, []).empty?
  if contract.customer.is_a?(Person) # TODO: clarify what to do when it's an Organization?
    contract.customer.add_role(Role::GROUP_MEMBER, localpool)
    contract.customer.add_role(Role::SELF, attrs[:customer])
    contract.customer.add_role(Role::CONTRACT, contract)
  end
  contract
end

contracts = {}

contracts[:pt1] = localpool_contract(
  customer: create(:person, :with_bank_account, first_name: 'Sabine', last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
  readings: [
    create(:reading, :setup, date: '2016-01-01', raw_value: 1_000),
    create(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000)
  ]
)

contracts[:pt2] = localpool_contract(
  customer: create(:person, :with_bank_account, first_name: 'Claudia', last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
  readings: [
    create(:reading, :setup, date: '2016-01-01', raw_value: 1_000),
    create(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000)
  ]
)

contracts[:pt3] = localpool_contract(
  signing_date: (Date.today - 5.days),
  begin_date: Date.today + 1.month,
  status: Contract::Base.statuses[:onboarding],
  customer: create(:person, :with_bank_account, first_name: 'Bernd', last_name: 'Powertaker3'),
  readings: [
    create(:reading, :setup, date: '2017-10-01', raw_value: 1_000)
  ]
)

contracts[:pt4] = localpool_contract(
  signing_date: Date.parse("2017-1-10"),
  begin_date: Date.parse("2017-2-1"),
  cancellation_date: Date.yesterday,
  end_date: Date.today + 1.month,
  status: Contract::Base.statuses[:terminated],
  customer: create(:person, :with_bank_account, first_name: 'Karlheinz', last_name: 'Powertaker4'),
  readings: [
    create(:reading, :setup, date: '2017-02-01', raw_value: 1_000)
  ]
)

# beendet, Auszug
contracts[:pt5a] = localpool_contract(
  cancellation_date: Date.parse("2017-3-10"),
  end_date: Date.parse("2017-4-1"),
  status: Contract::Base.statuses[:ended],
  customer: create(:person, :with_bank_account, first_name: 'Sylvia', last_name: 'Powertaker5a (zieht aus)', prefix: 'F'),
  readings: [
    create(:reading, :setup, date: '2016-01-01', raw_value: 1_000),
    create(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000),
    create(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000)
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
  customer: create(:organization, :with_bank_account, name: 'Hausverwaltung Schneider (Leerstand)'),
)

# zieht ein
contracts[:pt5b] = localpool_contract(
  signing_date: Date.parse("2017-4-10"),
  begin_date: Date.parse("2017-5-1"),
  register: contracts[:pt5a].register, # important !
  customer: create(:person, :with_bank_account, first_name: 'Fritz', last_name: 'Powertaker5b (zieht ein)'),
)

# Drittlieferant
contracts[:pt6] = localpool_contract(
  contractor: SeedsRepository.organizations.third_party,
  customer: create(:person, :with_bank_account, first_name: 'Horst', last_name: 'Powertaker6 (drittbeliefert)'),
)

# Drittlieferant, vor Wechsel zu people power
contracts[:pt7a] = localpool_contract(
  cancellation_date: Date.parse("2017-2-15"),
  end_date: Date.parse("2017-3-1"),
  status: Contract::Base.statuses[:ended],
  contractor: SeedsRepository.organizations.third_party,
  customer: create(:person, :with_bank_account, first_name: 'Anna', last_name: 'Powertaker7 (Wechsel zu uns)', prefix: 'F'),
)
contracts[:pt7a].customer.add_role(Role::GROUP_ENERGY_MENTOR, contracts[:pt7a].localpool)

# Drittlieferant, nach Wechsel zu people power
contracts[:pt7b] = localpool_contract(
  signing_date: contracts[:pt7a].cancellation_date,
  begin_date: contracts[:pt7a].end_date,
  customer: contracts[:pt7a].customer
)

# English
contracts[:pt8] = localpool_contract(
  customer: create(:person, :with_bank_account, first_name: 'Geoffrey',  last_name: 'Powertaker8', preferred_language: 'english')
)

# Two more powertakers to make them 10 ...
contracts[:pt9] = localpool_contract(
  customer: create(:person, :with_bank_account, first_name: 'Justine', last_name: 'Powertaker9', prefix: 'F')
)
contracts[:pt10] = localpool_contract(
  customer: create(:person, :with_bank_account, first_name: 'Mohammed',last_name: 'Powertaker10')
)

# Allgemeinstrom (Hausbeleuchtung etc.)
contracts[:common_consumption] = localpool_contract(
  contractor: SeedsRepository.localpools.people_power.owner,
  register: create(:register, :input, name: "Allgemeinstrom"),
  customer: SeedsRepository.localpools.people_power.owner
)

#
# More registers (without powertakers & contracts)
#
registers = {
  ecar:     create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other], group: SeedsRepository.localpools.people_power),
  grid_out: create(:register, :output, :grid_connected, name: 'Netzanschluss Einspeisung', label: Register::Base.labels[:grid_feeding], group: SeedsRepository.localpools.people_power,
                   meter: SeedsRepository.meters.grid,
                   readings: [
                     create(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40'),
                     create(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000)
                   ]
  ),
  grid_in: create(:register, :input, :grid_connected, name: 'Netzanschluss Bezug', group: SeedsRepository.localpools.people_power,
                   meter: SeedsRepository.meters.grid,
                   readings: [
                     create(:reading, :setup, date: '2016-01-01', raw_value: 2_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40'),
                     create(:reading, :regular, date: '2016-12-31', raw_value: 66_000_000)
                   ]
  ),
  bhkw:    create(:register, :output, name: 'Produktion BHKW', label: Register::Base.labels[:production_chp], group: SeedsRepository.localpools.people_power),
  pv:      create(:register, :output, name: 'Produktion PV', label: Register::Base.labels[:production_pv], group: SeedsRepository.localpools.people_power),
}

FactoryGirl.create(:device, :bhkw, commissioning: '1995-01-01', register: registers[:bhkw])
FactoryGirl.create(:device, :pv, commissioning: '2017-04-10', register: registers[:pv])
FactoryGirl.create(:device, :ecar, commissioning: '2017-04-10', register: registers[:ecar])

__END__

puts "\n* Energy Classifications"
%i(buzzn germany).each { |trait| create(:energy_classification, trait) }

import_csv(:payments,
           converters: { price_cents: Converters::Number, begin_date: Converters::Date, end_date: Converters::Date, cycle: Converters::Downcase, source: Converters::Downcase },
           fields: %i(price_cents begin_date end_date cycle source)
)

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
