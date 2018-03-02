SampleData.market_locations = OpenStruct.new

def create_market_location(name)
  FactoryGirl.create(:market_location, :with_market_location_id, name: name, group: SampleData.localpools.people_power)
end

names = [
  'Apartment 1',
  'Apartment 2',
  'Apartment 3',
  'Apartment 4 (terminated contract)',
  'Apartment 5 (has gap contract)',
  'Apartment 6 (3rd party)',
  'Apartment 7 (customer changed to us)',
  'Apartment 8 (English speaker)',
  'Apartment 9',
  'Apartment 10'
]
names.each.with_index(1) do |name, index|
  SampleData.market_locations.send("apartment_#{index}=", create_market_location(name))
end

SampleData.market_locations.common_consumption = create_market_location('Allgemeinstrom')
