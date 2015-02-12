Fabricator :metering_point do
  address_addition  'Verbrauch'
  i = 1
  uid                                    {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  registers                              { Fabricate(:meter).registers }
  electricity_supplier_contracts         { [Fabricate(:electricity_supplier_contract)] }
end




Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'in_out.jpg' ))  }
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
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'pv.jpg' )) }

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
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'ladesaeule.jpg' )) }
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
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'bhkw.jpg' )) }
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
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'belfortstr10', 'wohnung.jpg' ))}
end

#felix berlin
Fabricator :mp_urbanstr88, from: :metering_point do
  address_addition  '3Etage Links'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'urbanstr88', 'wohnung.jpg' )) }
  registers  { Fabricate(:urbanstr88_meter).registers }
end




# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address_addition  'Dach'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'gautinger_weg', 'pv.jpg' ))}
  registers { Fabricate(:easymeter_60051431).registers }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address_addition  'Keller'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'forstenrieder_weg', 'bhkw_stefan.jpg' ))}
  registers { Fabricate(:out_meter).registers }
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address_addition  'Acker'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'niensweg', 'wind.jpg' ))}
  registers { Fabricate(:out_meter).registers }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address_addition  'Wohnung'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg8', 'bezug.jpg' )) }
  registers { Fabricate(:easymeter_1124001747).registers }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :metering_point do
  address_addition  'Bezug'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'roentgenstrasse11', 'bezug.jpg' )) }
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
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'in_out.jpg' )) }
  registers { Fabricate(:easymeter_60118470).registers }
  electricity_supplier_contracts         { [] }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :metering_point do
  address_addition  'Keller'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'bhkw.jpg' ))}
  registers { Fabricate(:easymeter_60009316).registers }
  electricity_supplier_contracts         { [] }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :metering_point do
  address_addition  'Wohnung'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_thomas.jpg' ))}
  registers { Fabricate(:easymeter_60009272).registers }
  electricity_supplier_contracts         { [] }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :metering_point do
  address_addition  'Restaurant Beier'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'restaurant.jpg' ))}
  registers { Fabricate(:easymeter_60009348).registers }
  electricity_supplier_contracts         { [] }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :metering_point do
  address_addition  'Wohnung'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_hans.jpg' ))}
  electricity_supplier_contracts         { [] }
  registers { Fabricate(:virtual_meter_hopf).registers }
end




#Wagnis 4 - West Wohnung 02 - Dirk Mittelstaedt
Fabricator :mp_60009416, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009416).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 03 - Manuel Dmoch
Fabricator :mp_60009419, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009419).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 04 - Sibo Ahrens
Fabricator :mp_60009415, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009415).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 05 - Nicolas Sadoni
Fabricator :mp_60009418, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009418).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 11 - Josef Neu
Fabricator :mp_60009411, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009411).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 13 - Elisabeth Christiansen
Fabricator :mp_60009410, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009410).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 12 - Florian Butz
Fabricator :mp_60009407, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009407).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 15 - Ulrike Bez
Fabricator :mp_60009409, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009409).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - West Wohnung 15 - Rudolf Hassenstein
Fabricator :mp_60009435, from: :metering_point do
  address_addition  'Wohnung'
  registers { Fabricate(:easymeter_60009435).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Allgemeinstrom Haus West
Fabricator :mp_60009420, from: :metering_point do
  address_addition  'Allgemeinstrom Haus West'
  registers { Fabricate(:easymeter_60009420).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - PV
Fabricator :mp_60118460, from: :metering_point do
  address_addition  'PV'
  registers { Fabricate(:easymeter_60118460).registers }
  electricity_supplier_contracts         { [] }
end




#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :mp_60009386, from: :metering_point do
  address_addition  'Allgemeinstrom Haus Nord'
  registers { Fabricate(:easymeter_60009386).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :mp_60009445, from: :metering_point do
  address_addition  'Allgemeinstrom Haus Nord'
  registers { Fabricate(:easymeter_60009445).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :mp_60009446, from: :metering_point do
  address_addition  'Gäste Haus Ost 1+2'
  registers { Fabricate(:easymeter_60009446).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Laden EG
Fabricator :mp_60009390, from: :metering_point do
  address_addition  'Laden EG'
  registers { Fabricate(:easymeter_60009390).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 01
Fabricator :mp_60009387, from: :metering_point do
  address_addition  'Nord Wohnung 01'
  registers { Fabricate(:easymeter_60009387).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 10
Fabricator :mp_60009438, from: :metering_point do
  address_addition  'Nord Wohnung 10'
  registers { Fabricate(:easymeter_60009438).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 12
Fabricator :mp_60009440, from: :metering_point do
  address_addition  'Nord Wohnung 12'
  registers { Fabricate(:easymeter_60009440).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 15
Fabricator :mp_60009404, from: :metering_point do
  address_addition  'Nord Wohnung 15'
  registers { Fabricate(:easymeter_60009404).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 17
Fabricator :mp_60009405, from: :metering_point do
  address_addition  'Nord Wohnung 17'
  registers { Fabricate(:easymeter_60009405).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 18
Fabricator :mp_60009422, from: :metering_point do
  address_addition  'Nord Wohnung 18'
  registers { Fabricate(:easymeter_60009422).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 19
Fabricator :mp_60009425, from: :metering_point do
  address_addition  'Nord Wohnung 19'
  registers { Fabricate(:easymeter_60009425).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 20
Fabricator :mp_60009402, from: :metering_point do
  address_addition  'Nord Wohnung 20'
  registers { Fabricate(:easymeter_60009402).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Ost 03
Fabricator :mp_60009429, from: :metering_point do
  address_addition  'Ost 03'
  registers { Fabricate(:easymeter_60009429).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 12
Fabricator :mp_60009393, from: :metering_point do
  address_addition  'Ost Wohnung 12'
  registers { Fabricate(:easymeter_60009393).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 13
Fabricator :mp_60009442, from: :metering_point do
  address_addition  'Ost Wohnung 13'
  registers { Fabricate(:easymeter_60009442).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 15
Fabricator :mp_60009441, from: :metering_point do
  address_addition  'Ost Wohnung 15'
  registers { Fabricate(:easymeter_60009441).registers }
  electricity_supplier_contracts         { [] }
end

#Wagnis 4 - Übergabe
Fabricator :mp_60118484, from: :metering_point do
  address_addition  'Übergabe'
  registers { Fabricate(:easymeter_60118484).registers }
  electricity_supplier_contracts         { [] }
end




#Pickel Wasserkraft
Fabricator :mp_60051562, from: :metering_point do
  address_addition  'Wasserkraft'
  registers { Fabricate(:easymeter_60051562).registers }
  electricity_supplier_contracts         { [] }
end













