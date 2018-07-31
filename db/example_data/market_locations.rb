SampleData.market_locations = OpenStruct.new

def create_market_location(name, register)
  ml = FactoryGirl.create(:market_location, register: register)
  ml.register.meta.update(name: name)
  ml.register.meta
end

# names = [
#   'Apartment 1',
#   'Apartment 2',
#   'Apartment 3',
#   'Apartment 4 (terminated contract)',
#   'Apartment 5 (has gap contract)',
#   'Apartment 6 (3rd party)',
#   'Apartment 7 (customer changed to us)',
#   'Apartment 8 (English speaker)',
#   'Apartment 9',
#   'Apartment 10',
#   'Ladestation eAuto'
# ]
# names.each.with_index(1) do |name, index|
#   # Apartment 10      => apartment_10
#   # Ladestation eAuto => ladestation_eauto
#   var_name = name.split(' (').first.downcase.tr(' ', '_')
#   SampleData.market_locations.send("#{var_name}=", create_market_location(name))
# end

SampleData.market_locations.ladestation_eauto = create_market_location('Ladestation eAuto', create(:register, :consumption_common,
                                                                                  meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)))


SampleData.market_locations.common_consumption = create_market_location('Allgemeinstrom', create(:register, :consumption_common,
                                                                                                  meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)))

SampleData.market_locations.apartment_10 = create_market_location('Apartment 10', create(:register, :substitute,
                                                                            meter: build(:meter, :virtual, group: SampleData.localpools.people_power)))
