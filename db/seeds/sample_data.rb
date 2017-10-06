require_relative 'import_csv'

puts "seeds: loading sample data"

FactoryGirl.definition_file_paths = %w(spec/factories)
FactoryGirl.find_definitions

Group::Localpool.destroy_all
localpool_people_power = FactoryGirl.create(:localpool, :people_power)

10.times do
  FactoryGirl.create(:contract, :localpool_powertaker,
                     localpool: localpool_people_power,
                     customer: FactoryGirl.create(:person, :powertaker)
  )
end

FactoryGirl.create(:meter_real, :two_way, group: localpool_people_power)

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
