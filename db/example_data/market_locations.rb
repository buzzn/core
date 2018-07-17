SampleData.market_locations = OpenStruct.new

def create_market_location(name)
  FactoryGirl.create(:market_location, name: name)
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
  'Apartment 10',
  'Ladestation eAuto'
]
names.each.with_index(1) do |name, index|
  # Apartment 10      => apartment_10
  # Ladestation eAuto => ladestation_eauto
  var_name = name.split(' (').first.downcase.tr(' ', '_')
  SampleData.market_locations.send("#{var_name}=", create_market_location(name))
end

SampleData.market_locations.common_consumption = create_market_location('Allgemeinstrom')

SampleData.market_locations.ladestation_eauto.register = create(:register, :consumption_common,
                                                                meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power))
#devices: [build(:device, :ecar, commissioning: SampleData.localpools.people_power.start_date)])

SampleData.market_locations.common_consumption.register = create(:register, :consumption_common,
                                                                 meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power))

SampleData.market_locations.apartment_10.register = create(:register, :substitute,
                                                           meter: build(:meter, :virtual, group: SampleData.localpools.people_power))
