Fabricator :metering_point do
  address_addition  'Keller'
  i = 1
  uid               {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  register          { Fabricate(:meter).registers.first }
  contract          { Fabricate(:contract) }
end




Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'

  register {
    Fabricate( :meter,
                manufacturer_name:           'Elster',
                manufacturer_product_number: 'AS 1440',
                manufacturer_device_number:   '03353984',
                ).registers.first
  }

end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'

  register {
     Fabricate(:meter,
                manufacturer_name:           'Kamstrup',
                manufacturer_product_number: '382J',
                manufacturer_device_number:   '15028648',
                ).registers.first
  }
  devices           {[Fabricate(:dach_pv_justus)]}
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  register {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_number:  '382J',
              manufacturer_device_number:    '15028641',
              ).registers.first
  }
  devices           {[Fabricate(:carport_pv_justus)]}
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'Keller'
  register {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_number:  '382J',
              manufacturer_device_number:   '15028644',
              ).registers.first
  }
  devices           {[Fabricate(:bhkw_justus)]}
end



Fabricator :mp_z5, from: :metering_point do
  address_addition  'Keller'
  register {
    Fabricate(:easymeter_1124001747).registers.first
  }
  metering_service_provider_contract {Fabricate(:mspc_justus)}
end







# karins pv anlage
Fabricator :mp_z6, from: :metering_point do
  address_addition  'Scheune'
  register {
    Fabricate(:easymeter_60051431).registers.first
  }
  devices           {[Fabricate(:pv_karin)]}
  metering_service_provider_contract {Fabricate(:mspc_karin)}
end






# stefans verbrauch anlage
Fabricator :mp_z7, from: :metering_point do
  address_addition  'Scheune'
  register {
    Fabricate(:easymeter_1024000034).registers.first
  }
  devices           {[Fabricate(:pv_karin)]}
  metering_service_provider_contract {Fabricate(:mspc_karin)}
end





