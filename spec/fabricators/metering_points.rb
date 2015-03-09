Fabricator :metering_point do
  name  'Wohnung'
  i = 1
  uid         {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  registers   { [Fabricate(:register_in)] }
  contracts   { [ Fabricate(:electricity_supplier_contract)] }
end


Fabricator :mp_z1, from: :metering_point do
  name  'Übergabe'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg10', 'in_out.jpg' ))  }
  registers   { [Fabricate(:register_in),Fabricate(:register_out)] }
  meter       { Fabricate(:easymeter_60139082) }
end

Fabricator :mp_z2, from: :metering_point do
  name  'PV'
  registers   { [Fabricate(:register_out)] }
  meter       { Fabricate(:easymeter_60051599) }
end



Fabricator :mp_z3, from: :metering_point do
  name  'Ladestation'
  registers   { [Fabricate(:register_in)] }
  meter       { Fabricate(:easymeter_60051559) }
end


Fabricator :mp_z4, from: :metering_point do
  name  'BHKW'
  registers   { [Fabricate(:register_out)] }
  meter       { Fabricate(:easymeter_60051560) }
end



Fabricator :mp_z5, from: :metering_point do
  name  'Abgrenzung'
  registers   { [Fabricate(:register_out)] }
  meter       { Fabricate(:easymeter_60051600) }
end



#felix berlin
Fabricator :mp_urbanstr88, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Urbanstr', street_number: '88', zip: 81667, city: 'Berlin', state: 'Berlin') }
  name  'Wohnung'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'urbanstr88', 'wohnung.jpg' )) }
end




# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'PV Scheune'
  registers   { [Fabricate(:register_out)] }
  meter       { Fabricate(:easymeter_60051431) }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'BHKW'
  registers   { [Fabricate(:register_out)] }
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  name  'Windanlage'
  registers   { [Fabricate(:register_out)] }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  name  'Wohnung'
  image { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'fichtenweg8', 'bezug.jpg' )) }
  meter { Fabricate(:easymeter_1124001747) }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :metering_point do
  address        { Fabricate(:address, street_name: 'Röntgenstrasse', street_number: '11', zip: 86199, city: 'Augsburg', state: 'Bayern') }
  name  'Wohnung'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'roentgenstrasse11', 'bezug.jpg' )) }
  meter { Fabricate(:easymeter_60138988) }
end


# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :mp_60009269, from: :metering_point do
  name  'Wohnung'
  meter { Fabricate(:easymeter_60009269) }
end






# Z1  Nr. 60118470 für Hans-Dieter Hopf übergame  (Zweirichtungszähler)
Fabricator :mp_60118470, from: :metering_point do
  name  'Keller'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'in_out.jpg' )) }
  meter { Fabricate(:easymeter_60118470) }
  contracts         { [] }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :metering_point do
  name  'Keller'
  meter { Fabricate(:easymeter_60009316) }
  contracts         { [] }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :metering_point do
  name  'Wohnung'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_thomas.jpg' ))}
  meter { Fabricate(:easymeter_60009272) }
  contracts         { [] }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :metering_point do
  name  'Restaurant Beier'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'restaurant.jpg' ))}
  meter          { Fabricate(:easymeter_60009348) }
  contracts         { [] }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :metering_point do
  name  'Wohnung'
  image {File.new(Rails.root.join('db', 'seed_assets', 'locations', 'hopfstr', 'wohnung_hans.jpg' ))}
  contracts         { [] }
  meter          { Fabricate(:virtual_meter_hopf) }
end




#Wagnis 4 - West Wohnung 02 - Dirk Mittelstaedt
Fabricator :mp_60009416, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009416) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 03 - Manuel Dmoch
Fabricator :mp_60009419, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009419) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 04 - Sibo Ahrens
Fabricator :mp_60009415, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009415) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 05 - Nicolas Sadoni
Fabricator :mp_60009418, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009418) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 11 - Josef Neu
Fabricator :mp_60009411, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009411) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 13 - Elisabeth Christiansen
Fabricator :mp_60009410, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009410) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 12 - Florian Butz
Fabricator :mp_60009407, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009407) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 15 - Ulrike Bez
Fabricator :mp_60009409, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009409) }
  contracts         { [] }
end

#Wagnis 4 - West Wohnung 15 - Rudolf Hassenstein
Fabricator :mp_60009435, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009435) }
  contracts         { [] }
end

#Wagnis 4 - Allgemeinstrom Haus West
Fabricator :mp_60009420, from: :metering_point do
  name  'Allgemeinstrom Haus West'
  meter          { Fabricate(:easymeter_60009420) }
  contracts         { [] }
end

#Wagnis 4 - PV
Fabricator :mp_60118460, from: :metering_point do
  name  'PV'
  meter          { Fabricate(:easymeter_60118460) }
  registers      { [Fabricate(:register_out)] }
  contracts         { [] }
end




#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :mp_60009386, from: :metering_point do
  name  'Allgemeinstrom Haus Nord'
  meter          { Fabricate(:easymeter_60009386) }
  contracts         { [] }
end

#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :mp_60009445, from: :metering_point do
  name  'Allgemeinstrom Haus Nord'
  meter          { Fabricate(:easymeter_60009445) }
  contracts         { [] }
end

#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :mp_60009446, from: :metering_point do
  name  'Gäste Haus Ost 1+2'
  meter          { Fabricate(:easymeter_60009446) }
  contracts         { [] }
end

#Wagnis 4 - Laden EG
Fabricator :mp_60009390, from: :metering_point do
  name  'Laden EG'
  meter          { Fabricate(:easymeter_60009390) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 01
Fabricator :mp_60009387, from: :metering_point do
  name  'Nord Wohnung 01'
  meter          { Fabricate(:easymeter_60009387) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 10
Fabricator :mp_60009438, from: :metering_point do
  name  'Nord Wohnung 10'
  meter          { Fabricate(:easymeter_60009438) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 12
Fabricator :mp_60009440, from: :metering_point do
  name  'Nord Wohnung 12'
  meter          { Fabricate(:easymeter_60009440) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 15
Fabricator :mp_60009404, from: :metering_point do
  name  'Nord Wohnung 15'
  meter          { Fabricate(:easymeter_60009404) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 17
Fabricator :mp_60009405, from: :metering_point do
  name  'Nord Wohnung 17'
  meter          { Fabricate(:easymeter_60009405) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 18
Fabricator :mp_60009422, from: :metering_point do
  name  'Nord Wohnung 18'
  meter          { Fabricate(:easymeter_60009422) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 19
Fabricator :mp_60009425, from: :metering_point do
  name  'Nord Wohnung 19'
  meter          { Fabricate(:easymeter_60009425) }
  contracts         { [] }
end

#Wagnis 4 - Nord Wohnung 20
Fabricator :mp_60009402, from: :metering_point do
  name  'Nord Wohnung 20'
  meter          { Fabricate(:easymeter_60009402) }
  contracts         { [] }
end

#Wagnis 4 - Ost 03
Fabricator :mp_60009429, from: :metering_point do
  name  'Ost 03'
  meter          { Fabricate(:easymeter_60009429) }
  contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 12
Fabricator :mp_60009393, from: :metering_point do
  name  'Ost Wohnung 12'
  meter          { Fabricate(:easymeter_60009393) }
  contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 13
Fabricator :mp_60009442, from: :metering_point do
  name  'Ost Wohnung 13'
  meter          { Fabricate(:easymeter_60009442) }
  contracts         { [] }
end

#Wagnis 4 - Ost Wohnung 15
Fabricator :mp_60009441, from: :metering_point do
  name  'Ost Wohnung 15'
  meter          { Fabricate(:easymeter_60009441) }
  contracts         { [] }
end

#Wagnis 4 - Übergabe
Fabricator :mp_60118484, from: :metering_point do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  name  'Übergabe'
  meter          { Fabricate(:easymeter_60118484) }
  registers   { [Fabricate(:register_in),Fabricate(:register_out)] }
  contracts         { [] }
end




#Pickel Wasserkraft
Fabricator :mp_60051562, from: :metering_point do
  name  'Wasserkraft'
  meter          { Fabricate(:easymeter_60051562) }
  contracts         { [] }
end













