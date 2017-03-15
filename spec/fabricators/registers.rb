# coding: utf-8

# ALL registers can only be used via Fabricate.build or with an extra meter: some_meter attribute, as a register can not exist without a meter

['input', 'output', 'virtual'].each do |type|
  klass = "Register::#{type.camelize}".constantize

  Fabricator "#{type}_register", class_name: klass do
    name        { "#{type}_#{FFaker::Name.name[0..20]}" }
    uid         { "DE" + Random.new_seed.to_s.slice(0, 29) }
    readable    'friends'
    direction   { type == 'virtual' ? ['in', 'out'].sample : type.sub('put','') }
    created_at  { (rand*10).days.ago }
    # don't set a label for virtual registers as there is a bug in db:init
    if type == 'output'
      label     Register::Base::PRODUCTION_PV
    elsif type == 'input'
      label     Register::Base::CONSUMPTION
    end
  end

end


# real world registers

Fabricator :register_z1a, from: :input_register do
  name      'Netzanschluss Bezug'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
  label     Register::Base::GRID_CONSUMPTION
end


Fabricator :register_z1b, from: :output_register do
  name        'Netzanschluss Einspeisung'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
  label     Register::Base::GRID_FEEDING
end


Fabricator :register_z2, from: :output_register do
  name  'PV'
  readable    'world'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end


Fabricator :register_z3, from: :input_register do
  name  'Ladestation'
  readable    'world'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end

Fabricator :register_z4, from: :output_register do
  name  'BHKW'
  readable    'world'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
  label     Register::Base::PRODUCTION_CHP
end



Fabricator :register_z5, from: :output_register do
  name  'Abgrenzung'
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
  label     Register::Base::DEMARCATION_PV
end



#felix berlin
Fabricator :register_urbanstr88, from: :input_register do
  address  { Fabricate(:address, street_name: 'Urbanstr', street_number: '88', zip: 81667, city: 'Berlin', state: 'Berlin') }
  name  'Wohnung'
end




# karins pv anlage
Fabricator :register_pv_karin, from: :output_register do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'PV Scheune'
  devices { [Fabricate(:pv_karin)] }
end




# stefans bhkw anlage
Fabricator :register_stefans_bhkw, from: :output_register do
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'BHKW'
  readable    'world'
  label     Register::Base::PRODUCTION_CHP
end




# hof butenland windanlage
Fabricator :register_hof_butenland_wind, from: :output_register do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  name  'Windanlage'
  readable    'world'
end



# christian_schuetze verbrauch
Fabricator :register_cs_1, from: :input_register do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  name  'Wohnung'
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :register_60138988, from: :input_register do
  address        { Fabricate(:address, street_name: 'Röntgenstrasse', street_number: '11', zip: 86199, city: 'Augsburg', state: 'Bayern') }
  name  'Wohnung'
end

#Nr. 60232612 ist eigentlich Cohaus WA10 - N36 aber zu Testzwecken für kristian
Fabricator :register_kristian, from: :input_register do
  name  'Wohnung'
  readable    'friends'
end

# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :register_60009269, from: :input_register do
  name  'Wohnung'
end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :register_60232499, from: :input_register do
  name  'Am Pfannenstiel Discovergy'
end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :register_ferraris_001_amperix, from: :input_register do
  name  'Wohnung'
end






Fabricator :register_60118470, from: :output_register do
  name  'Keller'
  label Register::Base::GRID_CONSUMPTION
end

Fabricator :register_60009316, from: :output_register do
  name  'Keller'
  label Register::Base::GRID_FEEDING
end

Fabricator :register_60009272, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009348, from: :input_register do
  name  'Restaurant Beier'
end

Fabricator :register_hdh, from: :virtual_register do
  name  'Wohnung'
  direction 'in'
end




Fabricator :register_60009416, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009419, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009415, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009418, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009411, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009410, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009407, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009409, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009435, from: :input_register do
  name  'Wohnung'
end

Fabricator :register_60009420, from: :input_register do
  name  'Allgemeinstrom Haus West'
end

Fabricator :register_60118460, from: :output_register do
  name  'PV'
end




Fabricator :register_60009386, from: :input_register do
  name  'Allgemeinstrom Haus Nord'
end

Fabricator :register_60009445, from: :input_register do
  name  'Allgemeinstrom Haus Nord'
end

Fabricator :register_60009446, from: :input_register do
  name  'Gäste Haus Ost 1+2'
end

Fabricator :register_60009390, from: :input_register do
  name  'Laden EG'
  readable    'world'
end

Fabricator :register_60009387, from: :input_register do
  name  'Nord Wohnung 01'
end

Fabricator :register_60009438, from: :input_register do
  name  'Nord Wohnung 10'
end

Fabricator :register_60009440, from: :input_register do
  name  'Nord Wohnung 12'
end

Fabricator :register_60009404, from: :input_register do
  name  'Nord Wohnung 15'
end

Fabricator :register_60009405, from: :input_register do
  name  'Nord Wohnung 17'
end

Fabricator :register_60009422, from: :input_register do
  name  'Nord Wohnung 18'
end

Fabricator :register_60009425, from: :input_register do
  name  'Nord Wohnung 19'
end

Fabricator :register_60009402, from: :input_register do
  name  'Nord Wohnung 20'
end

Fabricator :register_60009429, from: :input_register do
  name  'Ost 03'
end

Fabricator :register_60009393, from: :input_register do
  name  'Ost Wohnung 12'
end

Fabricator :register_60009442, from: :input_register do
  name  'Ost Wohnung 13'
end

Fabricator :register_60009441, from: :input_register do
  name  'Ost Wohnung 15'
end

Fabricator :register_60118484, from: :input_register do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  name  'Übergabe'
  label Register::Base::GRID_CONSUMPTION
end




Fabricator :register_60051562, from: :input_register do
  name  'Wasserkraft'
  readable    'world'
end





#Ab hier: Hell & Warm (Forstenried)
Fabricator :register_60051595, from: :input_register do
  name      'S 43'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 43')}
end

Fabricator :register_60051547, from: :input_register do
  name      'M 21'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 5, addition: 'M 21')}
end

Fabricator :register_60051620, from: :input_register do
  name      'M 25'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 5, addition: 'M 25')}
end

Fabricator :register_60051602, from: :input_register do
  name      'S 25'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 25')}
end

Fabricator :register_60051618, from: :input_register do
  name      'M 14'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 5, addition: 'M 14')}
end

Fabricator :register_60051557, from: :input_register do
  name      'S 42'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 42')}
end

Fabricator :register_60051596, from: :input_register do
  name      'S 22'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 22')}
end

Fabricator :register_60051558, from: :input_register do
  name      'S 41'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 41')}
end

Fabricator :register_60051551, from: :input_register do
  name      'M 32'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 5, addition: 'M 32')}
end

Fabricator :register_60051619, from: :input_register do
  name      'M 13'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 5, addition: 'M 13')}
end

Fabricator :register_60051556, from: :input_register do
  name      'S 33'
  label     Register::Base::CONSUMPTION
  address   { Fabricate(:address_limmat, street_number: 7, addition: 'S 33')}
end

Fabricator :register_60051617, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 12'
end

Fabricator :register_60051555, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 32'
end

Fabricator :register_60051616, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 15'
end

Fabricator :register_60051615, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 16'
end

Fabricator :register_60051546, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 33'
end

#andreas kapfer
Fabricator :register_60051553, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 44'
end

Fabricator :register_60051601, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 23'
end

Fabricator :register_60051568, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 41'
end

Fabricator :register_60051610, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 24'
end

Fabricator :register_60051537, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 24'
end

Fabricator :register_60051564, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 22'
end

Fabricator :register_60051572, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 21'
end

Fabricator :register_60051552, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 42'
end

Fabricator :register_60051567, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 11'
end

Fabricator :register_60051586, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 43'
end

Fabricator :register_60051540, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 02'
end

Fabricator :register_60051578, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 34'
end

Fabricator :register_60051597, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 31'
end

Fabricator :register_60051541, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '4', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 17'
end

Fabricator :register_60051570, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 36'
end

Fabricator :register_60051548, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 31'
end

Fabricator :register_60051612, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 14'
end

Fabricator :register_60051549, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 34'
end

Fabricator :register_60051587, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 31'
end

Fabricator :register_60051566, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 45'
end

Fabricator :register_60051592, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 23'
end

Fabricator :register_60051580, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 24'
end

Fabricator :register_60051538, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 26'
end

Fabricator :register_60051590, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 25'
end

Fabricator :register_60051588, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 33'
end

Fabricator :register_60051543, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 03'
  #meter {  Fabricate(:easymeter_60051543) }
end

Fabricator :register_60051582, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 05'
  #meter {  Fabricate(:easymeter_60051582) }
end

Fabricator :register_60051539, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 05'
  #meter {  Fabricate(:easymeter_60051539) }
end

Fabricator :register_60051545, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 27'
  #meter {  Fabricate(:easymeter_60051545) }
end

Fabricator :register_60051614, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 04'
  #meter {  Fabricate(:easymeter_60051614) }
end

Fabricator :register_60051550, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 43'
  #meter {  Fabricate(:easymeter_60051550) }
end

Fabricator :register_60051573, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 23'
  #meter {  Fabricate(:easymeter_60051573) }
end

Fabricator :register_60051571, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 01'
  #meter {  Fabricate(:easymeter_60051571) }
end

Fabricator :register_60051544, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 04'
  #meter {  Fabricate(:easymeter_60051544) }
end

Fabricator :register_60051594, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 02'
  #meter {  Fabricate(:easymeter_60051594) }
end

Fabricator :register_60051583, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 04'
  #meter {  Fabricate(:easymeter_60051583) }
end

Fabricator :register_60051604, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 15'
  #meter {  Fabricate(:easymeter_60051604) }
end

Fabricator :register_60051593, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 35'
  #meter {  Fabricate(:easymeter_60051593) }
end

Fabricator :register_60051613, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 02'
  #meter {  Fabricate(:easymeter_60051613) }
end

Fabricator :register_60051611, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 12'
  #meter {  Fabricate(:easymeter_60051611) }
end

Fabricator :register_60051609, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 03'
  #meter {  Fabricate(:easymeter_60051609) }
end

Fabricator :register_60051554, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 06'
end

Fabricator :register_60051585, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 41'
end

Fabricator :register_60051621, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 11'
end

Fabricator :register_60051565, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 26'
end

#alexandra brunner
# Fabricator :register_60051595, from: :input_register do
#   #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 27'
# end

Fabricator :register_60051579, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
 name  'N 01'
 label Register::Base::CONSUMPTION
end

#third party supplied
Fabricator :register_60051575, from: :input_register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
 name  'N 42'
 label Register::Base::CONSUMPTION
end


# #peter schmidt
# Fabricator :register_6005195, from: :input_register do
#   #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'Übergabe'
# end

#abgrenzung pv
Fabricator :register_60009484, from: :output_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Abgrenzung PV'
  label Register::Base::DEMARCATION_PV
end

#bhkw1
Fabricator :register_60138947, from: :output_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'BHKW 1'
  label Register::Base::PRODUCTION_CHP
end

#bhkw2
Fabricator :register_60138943, from: :output_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'BHKW 2'
  label Register::Base::PRODUCTION_CHP
end

#pv
Fabricator :register_1338000816, from: :output_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'PV'
  label Register::Base::PRODUCTION_PV
end

#schule
Fabricator :register_60009485, from: :input_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Schule'
  label Register::Base::CONSUMPTION
end

#hst_mitte
Fabricator :register_1338000818, from: :input_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'HST Mitte'
  label Register::Base::CONSUMPTION
end

#übergabe in
Fabricator :register_1305004864, from: :input_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Netzanschluss Bezug'
  label Register::Base::GRID_CONSUMPTION
end

#übergabe out
Fabricator :register_1305004864_out, from: :output_register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Netzanschluss Einspeisung'
  label Register::Base::GRID_FEEDING
end

#virtueller Zählpunkt
Fabricator :register_forstenried_erzeugung, from: :output_register do
  name  'Gesamterzeugung'
  meter           nil
  virtual         true
  formula_parts   {[
                    Fabricate(:fp_plus, operand_id: Fabricate(:register_60138947).id),
                    Fabricate(:fp_plus, operand_id: Fabricate(:register_60138943).id),
                    Fabricate(:fp_minus, operand_id: Fabricate(:register_1338000816).id)
                  ]}
end

#virtueller Zählpunkt
Fabricator :register_forstenried_bezug, from: :input_register do
  name  'Gesamtverbrauch'
  virtual         true
end
