Fabricator :metering_point do
  address_addition  'Verbrauch'
  i = 1
  uid                                    {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  registers                              { Fabricate(:meter).registers }
  electricity_supplier_contracts         { [Fabricate(:electricity_supplier_contract)] }
end




Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'in_out.jpg' ))) ] }
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
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'pv.jpg' ))) ] }

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
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'ladesaeule.jpg' ))) ] }
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
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'bhkw.jpg' ))) ] }
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



#felix münchen
Fabricator :mp_belfortstr10, from: :metering_point do
  address_addition  '3Etage Rechts'
  assets {[Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'belfortstr10', 'wohnung.jpg' )))]}
end

#felix berlin
Fabricator :mp_urbanstr88, from: :metering_point do
  address_addition  '3Etage Links'
  assets {[Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'urbanstr88', 'wohnung.jpg' )))]}
end




# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address_addition  'Dach'
  assets {[Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'gautinger_weg', 'pv.jpg' )))]}
  registers { Fabricate(:easymeter_60051431).registers }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address_addition  'Keller'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'forstenrieder_weg', 'bhkw_stefan.jpg' ))) ] }
  registers { Fabricate(:out_meter).registers }
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address_addition  'Acker'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'niensweg', 'wind.jpg' ))) ] }
  registers { Fabricate(:out_meter).registers }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address_addition  'Wohnung'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg8', 'bezug.jpg' ))) ] }
  registers { Fabricate(:easymeter_1124001747).registers }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :metering_point do
  address_addition  'Bezug'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'roentgenstrasse11', 'bezug.jpg' ))) ] }
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
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'in_out.jpg' ))) ] }
  registers { Fabricate(:easymeter_60118470).registers }
  electricity_supplier_contracts         { [] }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :metering_point do
  address_addition  'Keller'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'bhkw.jpg' ))) ] }
  registers { Fabricate(:easymeter_60009316).registers }
  electricity_supplier_contracts         { [] }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :metering_point do
  address_addition  'Wohnung'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_thomas.jpg' ))) ] }
  registers { Fabricate(:easymeter_60009272).registers }
  electricity_supplier_contracts         { [] }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :metering_point do
  address_addition  'Restaurant Beier'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'restaurant.jpg' ))) ] }
  registers { Fabricate(:easymeter_60009348).registers }
  electricity_supplier_contracts         { [] }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :metering_point do
  address_addition  'Wohnung'
  assets { [  Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_hans.jpg' ))) ] }
  virtual true
  electricity_supplier_contracts         { [] }
end













