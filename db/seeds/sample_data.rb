require_relative 'import_csv'
require_relative 'seeds_repository'

puts "seeds: loading sample data"

FactoryGirl.definition_file_paths = %w(spec/factories)
FactoryGirl.find_definitions

#
# Create sample groups
#
Group::Localpool.destroy_all
localpool_people_power  = FactoryGirl.create(:localpool, :people_power)
localpool_hell_und_warm = FactoryGirl.create(:localpool, :hell_und_warm)

#
# Create persons and roles
#

# buzzn operator
operator = FactoryGirl.create(:person, first_name: 'Philipp',   last_name: 'Operator')
operator.add_role(Role::BUZZN_OPERATOR)

# group owner
owner = SeedsRepository.persons.wolfgang
owner.add_role(Role::GROUP_OWNER, localpool_people_power)

# Traudl Brumbauer, will be admin of several localpools
brumbauer = FactoryGirl.create(:person, first_name: 'Traudl',last_name: 'Brumbauer',                      prefix: 'F')
brumbauer.add_role(Role::GROUP_ADMIN, localpool_people_power) # can admin the organization
brumbauer.add_role(Role::ORGANIZATION, localpool_hell_und_warm) # can see the organization

powertakers = {
  pt1:  FactoryGirl.create(:person, first_name: 'Sabine',    last_name: 'Powertaker1', title: 'Prof.',     prefix: 'F'),
  pt2:  FactoryGirl.create(:person, first_name: 'Claudia',   last_name: 'Powertaker2', title: 'Prof. Dr.', prefix: 'F'),
  pt3:  FactoryGirl.create(:person, first_name: 'Bernd',     last_name: 'Powertaker3'),
  pt4:  FactoryGirl.create(:person, first_name: 'Karlheinz', last_name: 'Powertaker4'),
  pt5a: FactoryGirl.create(:person, first_name: 'Sylvia',    last_name: 'Powertaker5a (zieht ein)', prefix: 'F'),
  pt5b: FactoryGirl.create(:person, first_name: 'Fritz',     last_name: 'Powertaker5b (zieht aus)'),
  pt6:  FactoryGirl.create(:person, first_name: 'Horst',     last_name: 'Powertaker6 (drittbeliefert)'),
  pt7:  FactoryGirl.create(:person, first_name: 'Karla',     last_name: 'Powertaker7 (Mentor)',            prefix: 'F'),
  pt8:  FactoryGirl.create(:person, first_name: 'Geoffrey',  last_name: 'Powertaker8', preferred_language: 'english'),
  pt9:  FactoryGirl.create(:person, first_name: 'Justine',   last_name: 'Powertaker9',                     prefix: 'F'),
  pt10: FactoryGirl.create(:person, first_name: 'Mohammed',  last_name: 'Powertaker10')
}
powertakers.each do |_key, person|
  FactoryGirl.create(:contract, :localpool_powertaker, localpool: localpool_people_power, customer: person)
  person.add_role(Role::GROUP_MEMBER, localpool_people_power) # can see his group
end
powertakers[:pt1].add_role(Role::SELF, localpool_people_power) # can see his profile
powertakers[:pt1].add_role(Role::CONTRACT, localpool_people_power) # can see his contract

powertakers[:pt7].add_role(Role::GROUP_ENERGY_MENTOR, localpool_people_power)


#FactoryGirl.create(:meter_real, :two_way, group: localpool_people_power)

__END__

[Reading::Continuous, Reading::Single].each(&:destroy_all)
puts "\n* Readings"

import_csv(:readings,
           converters: {date: Converters::Date, raw_value: Converters::Number, value: Converters::Number },
           fields: %i(date raw_value reason read_by comment)
)

Person.destroy_all
import_csv(:persons,
           converters: {preferred_language: Converters::PreferredLanguage },
           fields: %i(first_name last_name email phone fax title  prefix preferred_language)
)
Person.all.each do |person|
  FactoryGirl.create(:bank_account, contracting_party: person)
end

Organization.destroy_all
import_csv(:organizations,
           converters: {preferred_language: Converters::PreferredLanguage },
           fields: %i(name description slug image email edifactemail phone fax website mode market_place_id)
)
Organization.all.each do |organization|
  FactoryGirl.create(:bank_account, contracting_party: organization)
end

Device.destroy_all
import_csv(:devices,
           converters: { watt_peak: Converters::Number, watt_hour_pa: Converters::Number, commissioning: Converters::Date, mobile: Converters::Boolean, primary_energy: Converters::Downcase },
           fields: %i(manufacturer_name manufacturer_product_name manufacturer_product_serialnumber mode law category primary_energy watt_peak watt_hour_pa commissioning mobile)
)

import_csv(:payments,
           converters: { price_cents: Converters::Number, begin_date: Converters::Date, end_date: Converters::Date, cycle: Converters::Downcase, source: Converters::Downcase },
           fields: %i(price_cents begin_date end_date cycle source)
)

puts "\n* Energy Classifications"
EnergyClassification.destroy_all
%i(buzzn germany).each { |trait| FactoryGirl.create(:energy_classification, trait) }
