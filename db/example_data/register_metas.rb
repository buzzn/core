SampleData.register_metas = OpenStruct.new

def create_register_meta(name, register)
  register.meta.update(name: name)
  register.meta
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
#   SampleData.register_metas.send("#{var_name}=", create_register_meta(name))
# end

SampleData.register_metas.ladestation_eauto = create_register_meta('Ladestation eAuto', create(:register, :consumption_common,
                                                                                  meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)))


SampleData.register_metas.common_consumption = create_register_meta('Allgemeinstrom', create(:register, :consumption_common,
                                                                                                  meter: build(:meter, :real, :one_way, group: SampleData.localpools.people_power)))

SampleData.register_metas.apartment_10 = create_register_meta('Apartment 10', create(:register, :substitute,
                                                                            meter: build(:meter, :virtual, group: SampleData.localpools.people_power)))
