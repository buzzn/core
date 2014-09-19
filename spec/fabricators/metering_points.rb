Fabricator :metering_point do
  address_addition  'Verbrauch'
  i = 1
  uid                                    {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  registers                              { Fabricate(:meter).registers }
  electricity_supplier_contracts         { [Fabricate(:electricity_supplier_contract)] }
end




Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'

  registers {
    Fabricate( :in_out_meter,
                manufacturer_name:           'Elster',
                manufacturer_product_name: 'AS 1440',
                manufacturer_product_serialnumber:   '03353984',
                ).registers
  }

end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'

  registers {
     Fabricate(:out_meter,
                manufacturer_name:           'Kamstrup',
                manufacturer_product_name: '382J',
                manufacturer_product_serialnumber:   '15028648',
                ).registers
  }
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  registers {
    Fabricate(:out_meter,
              manufacturer_name: 'Kamstrup',
              manufacturer_product_name: '382J',
              manufacturer_product_serialnumber: '15028641',
              ).registers
  }
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'Keller'
  registers {
    Fabricate(:out_meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_name:  '382J',
              manufacturer_product_serialnumber:   '15028644',
              ).registers
  }
end



Fabricator :mp_z5, from: :metering_point do
  address_addition  'Keller'
end





# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address_addition  'Photovoltaik'
  registers { Fabricate(:easymeter_60051431).registers }
  metering_service_provider_contracts {[Fabricate(:mspc_karin)]}
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address_addition  'BHKW Keller'
  registers { Fabricate(:in_out_meter).registers }
  metering_service_provider_contracts {[Fabricate(:mspc_stefan)]}
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address_addition  'Acker'
  registers { Fabricate(:out_meter).registers }
  metering_service_provider_contracts { [Fabricate(:metering_service_provider_contract)] }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_1124001747).registers }
  metering_service_provider_contracts {[Fabricate(:mspc_justus)]}
end

















