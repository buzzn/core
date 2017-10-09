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
operator = create(:person, first_name: 'Philipp',   last_name: 'Operator')
operator.add_role(Role::BUZZN_OPERATOR)

# group owner
owner = SeedsRepository.persons.wolfgang
owner.add_role(Role::GROUP_OWNER, SeedsRepository.localpools.people_power)

# Traudl Brumbauer, will be admin of several localpools
brumbauer = create(:person, first_name: 'Traudl',last_name: 'Brumbauer', prefix: 'F')
brumbauer.add_role(Role::GROUP_ADMIN, SeedsRepository.localpools.people_power) # can admin the organization
brumbauer.add_role(Role::ORGANIZATION, SeedsRepository.localpools.hell_un) # can see the organization

readings_attributes = {
  pt1: [
    attributes_for(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    attributes_for(:reading, :regular, date: '2016-12-31', raw_value: 2_400_000, register: nil)
  ],
  pt2: [
    attributes_for(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    attributes_for(:reading, :regular, date: '2016-12-31', raw_value: 4_500_000, register: nil)
  ],
  pt3: [
    attributes_for(:reading, :setup, date: '2017-10-01', raw_value: 1_000, register: nil)
  ],
  pt4: [
    attributes_for(:reading, :setup, date: '2017-02-01', raw_value: 1_000, register: nil)
  ],
  pt5a: [
    attributes_for(:reading, :setup, date: '2016-01-01', raw_value: 1_000, register: nil),
    attributes_for(:reading, :regular, date: '2016-12-31', raw_value: 1_300_000, register: nil),
    attributes_for(:reading, :contract_change, date: '2017-04-01', raw_value: 1_765_000, register: nil)
  ]
}

#
# Powertakers
#
powertakers = {
  pt1:  create(:person, :with_bank_account, first_name: 'Sabine',    last_name: 'Powertaker1', title: 'Prof.', prefix: 'F'),
  pt2:  create(:person, :with_bank_account, first_name: 'Claudia',   last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
  pt3:  create(:person, :with_bank_account, first_name: 'Bernd',     last_name: 'Powertaker3'),
  pt4:  create(:person, :with_bank_account, first_name: 'Karlheinz', last_name: 'Powertaker4'),
  pt5a: create(:person, :with_bank_account, first_name: 'Sylvia',    last_name: 'Powertaker5a (zieht ein)', prefix: 'F'),
  pt5b: create(:person, :with_bank_account, first_name: 'Fritz',     last_name: 'Powertaker5b (zieht aus)'),
  pt6:  create(:person, :with_bank_account, first_name: 'Horst',     last_name: 'Powertaker6 (drittbeliefert)'),
  pt7:  create(:person, :with_bank_account, first_name: 'Karla',     last_name: 'Powertaker7 (Mentor)', prefix: 'F'),
  pt8:  create(:person, :with_bank_account, first_name: 'Geoffrey',  last_name: 'Powertaker8', preferred_language: 'english'),
  pt9:  create(:person, :with_bank_account, first_name: 'Justine',   last_name: 'Powertaker9', prefix: 'F'),
  pt10: create(:person, :with_bank_account, first_name: 'Mohammed',  last_name: 'Powertaker10')
}
powertakers.each do |key, person|
  contract = create(:contract, :localpool_powertaker,
    localpool: SeedsRepository.localpools.people_power,
    contractor: SeedsRepository.localpools.people_power.owner,
    customer: person
  )
  # add readings if given
  readings_attributes.fetch(key, []).each { |attrs| contract.register.readings.create!(attrs.except(:register)) }
  person.add_role(Role::GROUP_MEMBER, SeedsRepository.localpools.people_power) # can see his group
end
powertakers[:pt1].add_role(Role::SELF, SeedsRepository.localpools.people_power) # can see his profile
powertakers[:pt1].add_role(Role::CONTRACT, SeedsRepository.localpools.people_power) # can see his contract

powertakers[:pt7].add_role(Role::GROUP_ENERGY_MENTOR, SeedsRepository.localpools.people_power)

#
# Further registers (without powertakers)
#
registers = {
  common:   create(:register, :input, name: 'Allgemeinstrom', group: SeedsRepository.localpools.people_power),
  ecar:     create(:register, :input, name: 'Ladestation eAuto', label: Register::Base.labels[:other], group: SeedsRepository.localpools.people_power),
  grid_out: create(:register, :output, name: 'Netzanschluss Einspeisung', label: Register::Base.labels[:grid_feeding], group: SeedsRepository.localpools.people_power,
                   meter: SeedsRepository.meters.grid,
                   readings: [
                     create(:reading, :setup, date: '2016-01-01', raw_value: 1_000, comment: 'Ablesung bei Einbau; Wandlerfaktor 40'),
                     create(:reading, :regular, date: '2016-12-31', raw_value: 12_000_000)
                   ]
  ),
  grid_in: create(:register, :input, name: 'Netzanschluss Bezug', group: SeedsRepository.localpools.people_power,
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
