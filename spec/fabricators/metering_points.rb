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
                manufacturer_name:                    'Easymeter',
                manufacturer_product_name:            'Q3D',
                manufacturer_product_serialnumber:    '60139082',
                ).registers
  }

end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'PV'
  registers {
     Fabricate(:out_meter,
                manufacturer_name:                    'Easymeter',
                manufacturer_product_name:            'Q3D',
                manufacturer_product_serialnumber:    '60051599',
                ).registers
  }
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Ladestation'
  registers {
    Fabricate(:in_meter,
              manufacturer_name:                  'Easymeter',
              manufacturer_product_name:          'Q3D',
              manufacturer_product_serialnumber:  '60051559',
              ).registers
  }
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'BHKW'
  registers {
    Fabricate(:out_meter,
              manufacturer_name:                    'Easymeter',
              manufacturer_product_name:            'Q3D',
              manufacturer_product_serialnumber:    '60051560',
              ).registers
  }
end



Fabricator :mp_z5, from: :metering_point do
  address_addition  'Abgrenzung'
  registers {
    Fabricate(:out_meter,
              manufacturer_name:                    'Easymeter',
              manufacturer_product_name:            'Q3D',
              manufacturer_product_serialnumber:    '60051600',
              ).registers
  }
end





# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address_addition  'Dach'
  registers { Fabricate(:easymeter_60051431).registers }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address_addition  'Keller'
  registers { Fabricate(:in_out_meter).registers }
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address_addition  'Acker'
  registers { Fabricate(:out_meter).registers }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_1124001747).registers }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :metering_point do
  address_addition  'Bezug'
  registers { Fabricate(:easymeter_60138988).registers }
end


# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :mp_60009269, from: :metering_point do
  address_addition  'Bezug'
  registers { Fabricate(:easymeter_60009269).registers }
end






# Z1  Nr. 60118470 für Hans-Dieter Hopf übergame  (Zweirichtungszähler)
Fabricator :mp_60118470, from: :metering_point do
  address_addition  'Keller'
  registers { Fabricate(:easymeter_60118470).registers }
  electricity_supplier_contracts         { [] }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :metering_point do
  address_addition  'Keller'
  registers { Fabricate(:easymeter_60009316).registers }
  electricity_supplier_contracts         { [] }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009272).registers }
  electricity_supplier_contracts         { [] }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :metering_point do
  address_addition  'Restaurant Beier'
  registers { Fabricate(:easymeter_60009348).registers }
  electricity_supplier_contracts         { [] }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :metering_point do
  address_addition  'Wohnung'
  virtual true
  electricity_supplier_contracts         { [] }
end













