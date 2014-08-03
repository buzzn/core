Fabricator :metering_point do
  address_addition  'Keller'
  i = 1
  uid               {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  registers          { Fabricate(:meter).registers }
  contract          { Fabricate(:contract) }
end




Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'

  registers {
    Fabricate( :meter,
                manufacturer_name:           'Elster',
                manufacturer_product_name: 'AS 1440',
                manufacturer_product_serialnumber:   '03353984',
                ).registers
  }

end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'

  registers {
     Fabricate(:meter,
                manufacturer_name:           'Kamstrup',
                manufacturer_product_name: '382J',
                manufacturer_product_serialnumber:   '15028648',
                ).registers
  }
  devices           {[Fabricate(:dach_pv_justus)]}
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  registers {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_name:  '382J',
              manufacturer_product_serialnumber:    '15028641',
              ).registers
  }
  devices           {[Fabricate(:carport_pv_justus)]}
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'Keller'
  registers {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_name:  '382J',
              manufacturer_product_serialnumber:   '15028644',
              ).registers
  }
  devices           {[Fabricate(:bhkw_justus)]}
end



Fabricator :mp_z5, from: :metering_point do
  address_addition  'Keller'
  registers {
    Fabricate(:easymeter_1124001747).registers
  }
  metering_service_provider_contract {Fabricate(:mspc_justus)}
end





# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address_addition  'Scheune'
  registers { Fabricate(:easymeter_60051431).registers }
  devices   {[Fabricate(:pv_karin)]}
  metering_service_provider_contract {Fabricate(:mspc_karin)}
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address_addition  'keller'
  registers { Fabricate(:in_out_meter).registers }
  devices   { [Fabricate(:bhkw_stefan)] }
  metering_service_provider_contract {Fabricate(:mspc_stefan)}
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address_addition  'Acker2'
  registers { Fabricate(:out_meter).registers }
  devices   { [Fabricate(:hof_butenland_wind)] }
  metering_service_provider_contract { Fabricate(:metering_service_provider_contract) }
end







