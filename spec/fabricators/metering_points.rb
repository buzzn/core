# coding: utf-8


Fabricator :register do
  name        'Wohnung'
  uid         { sequence(:uid, 10688251510000000000002677114) }
  mode        'in'
  readable    'friends'
  #contracts   { [ Fabricate(:power_taker_contract)] }
end

Fabricator :register_readable_by_world, from: :register do
  readable    'world'
end

Fabricator :out_register_readable_by_world, from: :register do
  readable    'world'
  mode        'out'
end

Fabricator :register_readable_by_friends, from: :register do
  readable    'friends'
end

Fabricator :register_readable_by_community, from: :register do
  readable    'community'
end

Fabricator :register_readable_by_members, from: :register do
  readable    'members'
end

Fabricator :world_register_with_two_comments, from: :register do
  readable    'world'
  after_create { |register|
    comment_params  = {
      commentable_id:     register.id,
      commentable_type:   'Register',
      parent_id:          '',
    }
    comment         = Fabricate(:comment, comment_params)
    comment_params[:parent_id] = comment.id
    comment2        = Fabricate(:comment, comment_params)
  }
end


Fabricator :register_with_device, from: :register do
  devices  { [Fabricate(:device)] }
end

Fabricator :register_with_manager, from: :register do
  after_create { |register|
    user = Fabricate(:user)
    user.add_role(:manager, register)
  }
end


Fabricator :out_register_with_manager, from: :register_with_manager do
  mode 'out'
end


Fabricator :mp_z1a, from: :register do
  name      'Netzanschluss Bezug'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end


Fabricator :mp_z1b, from: :register do
  name        'Netzanschluss Einspeisung'
  mode        'out'
  contracts   { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end


Fabricator :mp_z2, from: :register do
  name  'PV'
  readable    'world'
  mode        'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end



Fabricator :mp_z3, from: :register do
  name  'Ladestation'
  readable    'world'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end


Fabricator :mp_z4, from: :register do
  name  'BHKW'
  readable    'world'
  mode        'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end



Fabricator :mp_z5, from: :register do
  name  'Abgrenzung'
  mode        'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  address   { Fabricate(:address, street_name: 'Lützowplatz', street_number: '123', zip: 81667, city: 'Berlin', state: 'Berlin') }
end



#felix berlin
Fabricator :mp_urbanstr88, from: :register do
  address  { Fabricate(:address, street_name: 'Urbanstr', street_number: '88', zip: 81667, city: 'Berlin', state: 'Berlin') }
  name  'Wohnung'
end




# karins pv anlage
Fabricator :mp_pv_karin, from: :register do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'PV Scheune'
  mode        'out'
  meter       { Fabricate(:easymeter_60051431) }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :register do
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'BHKW'
  readable    'world'
  mode        'out'
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :register do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  name  'Windanlage'
  readable    'world'
  mode        'out'
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :register do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  name  'Wohnung'
  meter { Fabricate(:easymeter_1124001747) }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :register do
  address        { Fabricate(:address, street_name: 'Röntgenstrasse', street_number: '11', zip: 86199, city: 'Augsburg', state: 'Bayern') }
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60138988) }
end

#Nr. 60232612 ist eigentlich Cohaus WA10 - N36 aber zu Testzwecken für kristian
Fabricator :mp_kristian, from: :register do
  name  'Wohnung'
  readable    'friends'
  mode        'in'
  meter {  Fabricate(:easymeter_60232612) }
end

# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :mp_60009269, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009269) }
end

# # Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
# Fabricator :mp_60232499, from: :register do
#   name  'Am Pfannenstiel Discovergy'
#   meter { Fabricate(:easymeter_60232499) }
# end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :mp_ferraris_001_amperix, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:ferraris_001_amperix) }
end






# Z1  Nr. 60118470 für Hans-Dieter Hopf übergabe  (Zweirichtungszähler)
Fabricator :mp_60118470, from: :register do
  name  'Keller'
  mode        'out'
  meter {  Fabricate(:easymeter_60118470) }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :register do
  name  'Keller'
  mode        'out'
  meter {  Fabricate(:easymeter_60009316) }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009272) }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :register do
  name  'Restaurant Beier'
  meter {  Fabricate(:easymeter_60009348) }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:virtual_meter_hopf) }
  virtual         true
end




#Wagnis 4 - West Wohnung 02 - Dirk Mittelstaedt
Fabricator :mp_60009416, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009416) }
end

#Wagnis 4 - West Wohnung 03 - Manuel Dmoch
Fabricator :mp_60009419, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009419) }
end

#Wagnis 4 - West Wohnung 04 - Sibo Ahrens
Fabricator :mp_60009415, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009415) }
end

#Wagnis 4 - West Wohnung 05 - Nicolas Sadoni
Fabricator :mp_60009418, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009418) }
end

#Wagnis 4 - West Wohnung 11 - Josef Neu
Fabricator :mp_60009411, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009411) }
end

#Wagnis 4 - West Wohnung 13 - Elisabeth Christiansen
Fabricator :mp_60009410, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009410) }
end

#Wagnis 4 - West Wohnung 12 - Florian Butz
Fabricator :mp_60009407, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009407) }
end

#Wagnis 4 - West Wohnung 15 - Ulrike Bez
Fabricator :mp_60009409, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009409) }
end

#Wagnis 4 - West Wohnung 15 - Rudolf Hassenstein
Fabricator :mp_60009435, from: :register do
  name  'Wohnung'
  meter {  Fabricate(:easymeter_60009435) }
end

#Wagnis 4 - Allgemeinstrom Haus West
Fabricator :mp_60009420, from: :register do
  name  'Allgemeinstrom Haus West'
  meter {  Fabricate(:easymeter_60009420) }
end

#Wagnis 4 - PV
Fabricator :mp_60118460, from: :register do
  name  'PV'
  meter {  Fabricate(:easymeter_60118460) }
  mode        'out'
end




#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :mp_60009386, from: :register do
  name  'Allgemeinstrom Haus Nord'
  meter {  Fabricate(:easymeter_60009386) }
end

#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :mp_60009445, from: :register do
  name  'Allgemeinstrom Haus Nord'
  meter {  Fabricate(:easymeter_60009445) }
end

#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :mp_60009446, from: :register do
  name  'Gäste Haus Ost 1+2'
  meter {  Fabricate(:easymeter_60009446) }
end

#Wagnis 4 - Laden EG
Fabricator :mp_60009390, from: :register do
  name  'Laden EG'
  readable    'world'
  meter {  Fabricate(:easymeter_60009390) }
end

#Wagnis 4 - Nord Wohnung 01
Fabricator :mp_60009387, from: :register do
  name  'Nord Wohnung 01'
  meter {  Fabricate(:easymeter_60009387) }
end

#Wagnis 4 - Nord Wohnung 10
Fabricator :mp_60009438, from: :register do
  name  'Nord Wohnung 10'
  meter {  Fabricate(:easymeter_60009438) }
end

#Wagnis 4 - Nord Wohnung 12
Fabricator :mp_60009440, from: :register do
  name  'Nord Wohnung 12'
  meter {  Fabricate(:easymeter_60009440) }
end

#Wagnis 4 - Nord Wohnung 15
Fabricator :mp_60009404, from: :register do
  name  'Nord Wohnung 15'
  meter {  Fabricate(:easymeter_60009404) }
end

#Wagnis 4 - Nord Wohnung 17
Fabricator :mp_60009405, from: :register do
  name  'Nord Wohnung 17'
  meter {  Fabricate(:easymeter_60009405) }
end

#Wagnis 4 - Nord Wohnung 18
Fabricator :mp_60009422, from: :register do
  name  'Nord Wohnung 18'
  meter {  Fabricate(:easymeter_60009422) }
end

#Wagnis 4 - Nord Wohnung 19
Fabricator :mp_60009425, from: :register do
  name  'Nord Wohnung 19'
  meter {  Fabricate(:easymeter_60009425) }
end

#Wagnis 4 - Nord Wohnung 20
Fabricator :mp_60009402, from: :register do
  name  'Nord Wohnung 20'
  meter {  Fabricate(:easymeter_60009402) }
end

#Wagnis 4 - Ost 03
Fabricator :mp_60009429, from: :register do
  name  'Ost 03'
  meter {  Fabricate(:easymeter_60009429) }
end

#Wagnis 4 - Ost Wohnung 12
Fabricator :mp_60009393, from: :register do
  name  'Ost Wohnung 12'
  meter {  Fabricate(:easymeter_60009393) }
end

#Wagnis 4 - Ost Wohnung 13
Fabricator :mp_60009442, from: :register do
  name  'Ost Wohnung 13'
  meter {  Fabricate(:easymeter_60009442) }
end

#Wagnis 4 - Ost Wohnung 15
Fabricator :mp_60009441, from: :register do
  name  'Ost Wohnung 15'
  meter {  Fabricate(:easymeter_60009441) }
end

#Wagnis 4 - Übergabe
Fabricator :mp_60118484, from: :register do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  name  'Übergabe'
  meter {  Fabricate(:easymeter_60118484) }
end




#Pickel Wasserkraft
Fabricator :mp_60051562, from: :register do
  name  'Wasserkraft'
  readable    'world'
  meter {  Fabricate(:easymeter_60051562) }
end





#Ab hier: Hell & Warm (Forstenried)
#Markus Becher
Fabricator :mp_60051595, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 43'
  meter {  Fabricate(:easymeter_60051595) }
end

#inge_brack
Fabricator :mp_60051547, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 21'
  meter {  Fabricate(:easymeter_60051547) }
end

#peter brack
Fabricator :mp_60051620, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 25'
  meter {  Fabricate(:easymeter_60051620) }
end

#annika brandl
Fabricator :mp_60051602, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 25'
  meter {  Fabricate(:easymeter_60051602) }
end

#gudrun brandl
Fabricator :mp_60051618, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 14'
  meter {  Fabricate(:easymeter_60051618) }
end

#martin bräunlich
Fabricator :mp_60051557, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 42'
  meter {  Fabricate(:easymeter_60051557) }
end

#daniel bruno
Fabricator :mp_60051596, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 22'
  meter {  Fabricate(:easymeter_60051596) }
end

#zubair butt
Fabricator :mp_60051558, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 41'
  meter {  Fabricate(:easymeter_60051558) }
end

#maria cerghizan
Fabricator :mp_60051551, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M32'
  meter {  Fabricate(:easymeter_60051551) }
end

#stefan csizmadia
Fabricator :mp_60051619, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M13'
  meter {  Fabricate(:easymeter_60051619) }
end

#patrick fierley
Fabricator :mp_60051556, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 33'
  meter {  Fabricate(:easymeter_60051556) }
end

#maria frank
Fabricator :mp_60051617, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 12'
  meter {  Fabricate(:easymeter_60051617) }
end

#eva galow
Fabricator :mp_60051555, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 32'
  meter {  Fabricate(:easymeter_60051555) }
end

#christel guesgen
Fabricator :mp_60051616, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 15'
  meter {  Fabricate(:easymeter_60051616) }
end

#gilda hencke
Fabricator :mp_60051615, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 16'
  meter {  Fabricate(:easymeter_60051615) }
end

#uwe hetzer
Fabricator :mp_60051546, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 33'
  meter {  Fabricate(:easymeter_60051546) }
end

#andreas kapfer
Fabricator :mp_60051553, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 44'
  meter {  Fabricate(:easymeter_60051553) }
end

#renate koller
Fabricator :mp_60051601, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 23'
  meter {  Fabricate(:easymeter_60051601) }
end

#thekla lorber
Fabricator :mp_60051568, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 41'
  meter {  Fabricate(:easymeter_60051568) }
end
#ludwig maaßen
Fabricator :mp_60051610, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 24'
  meter {  Fabricate(:easymeter_60051610) }
end

#franz petschler
Fabricator :mp_60051537, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 24'
  meter {  Fabricate(:easymeter_60051537) }
end

#anna pfaffel
Fabricator :mp_60051564, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 22'
  meter {  Fabricate(:easymeter_60051564) }
end

#cornelia roth
Fabricator :mp_60051572, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 21'
  meter {  Fabricate(:easymeter_60051572) }
end

#christian voigt
Fabricator :mp_60051552, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 42'
  meter {  Fabricate(:easymeter_60051552) }
end

#claudia weber
Fabricator :mp_60051567, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 11'
  meter {  Fabricate(:easymeter_60051567) }
end

#sissi banos
Fabricator :mp_60051586, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 43'
  meter {  Fabricate(:easymeter_60051586) }
end

#laura häusler
Fabricator :mp_60051540, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 02'
  meter {  Fabricate(:easymeter_60051540) }
end

#bastian hentschel
Fabricator :mp_60051578, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 34'
  meter {  Fabricate(:easymeter_60051578) }
end

#dagmar holland
Fabricator :mp_60051597, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 31'
  meter {  Fabricate(:easymeter_60051597) }
end

#ahmad majid
Fabricator :mp_60051541, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '4', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 17'
  meter {  Fabricate(:easymeter_60051541) }
end

#marinus meiners
Fabricator :mp_60051570, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 36'
  meter {  Fabricate(:easymeter_60051570) }
end

#wolfgang pfaffel
Fabricator :mp_60051548, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 31'
  meter {  Fabricate(:easymeter_60051548) }
end

#magali thomas
Fabricator :mp_60051612, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 14'
  meter {  Fabricate(:easymeter_60051612) }
end

#kathrin kaisenberg
Fabricator :mp_60051549, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 34'
  meter {  Fabricate(:easymeter_60051549) }
end

#christian winkler
Fabricator :mp_60051587, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 31'
  meter {  Fabricate(:easymeter_60051587) }
end

#dorothea wolff
Fabricator :mp_60051566, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 45'
  meter {  Fabricate(:easymeter_60051566) }
end

#esra kwiek
Fabricator :mp_60051592, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 23'
  meter {  Fabricate(:easymeter_60051592) }
end

#felix pfeiffer
Fabricator :mp_60051580, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 24'
  meter {  Fabricate(:easymeter_60051580) }
end

#jorg nasri
Fabricator :mp_60051538, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 26'
  meter {  Fabricate(:easymeter_60051538) }
end

#ruth jürgensen
Fabricator :mp_60051590, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 25'
  meter {  Fabricate(:easymeter_60051590) }
end

#rafal jaskolka
Fabricator :mp_60051588, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 33'
  meter {  Fabricate(:easymeter_60051588) }
end

#elisabeth gritzmann
Fabricator :mp_60051543, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 03'
  meter {  Fabricate(:easymeter_60051543) }
end

#matthias flegel
Fabricator :mp_60051582, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 05'
  meter {  Fabricate(:easymeter_60051582) }
end

#michael göbl
Fabricator :mp_60051539, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 05'
  meter {  Fabricate(:easymeter_60051539) }
end

#joaquim gongolo
Fabricator :mp_60051545, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 27'
  meter {  Fabricate(:easymeter_60051545) }
end

#patrick haas
Fabricator :mp_60051614, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 04'
  meter {  Fabricate(:easymeter_60051614) }
end

#gundula herrenberg
Fabricator :mp_60051550, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 43'
  meter {  Fabricate(:easymeter_60051550) }
end

#dominik sölch
Fabricator :mp_60051573, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 23'
  meter {  Fabricate(:easymeter_60051573) }
end

#jessica rensburg
Fabricator :mp_60051571, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 01'
  meter {  Fabricate(:easymeter_60051571) }
end

#ulrich hafen
Fabricator :mp_60051544, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 04'
  meter {  Fabricate(:easymeter_60051544) }
end

#anke merk
Fabricator :mp_60051594, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 02'
  meter {  Fabricate(:easymeter_60051594) }
end

#alex erdl
Fabricator :mp_60051583, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 04'
  meter {  Fabricate(:easymeter_60051583) }
end

#katrin frische
Fabricator :mp_60051604, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 15'
  meter {  Fabricate(:easymeter_60051604) }
end

#claudia krumm
Fabricator :mp_60051593, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 35'
  meter {  Fabricate(:easymeter_60051593) }
end

#rasim abazovic
Fabricator :mp_60051613, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 02'
  meter {  Fabricate(:easymeter_60051613) }
end

#moritz feith
Fabricator :mp_60051611, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 12'
  meter {  Fabricate(:easymeter_60051611) }
end

#irmgard loderer
Fabricator :mp_60051609, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '7', zip: 81476, city: 'München', state: 'Bayern') }
  name  'S 03'
  meter {  Fabricate(:easymeter_60051609) }
end

#eunice schüler
Fabricator :mp_60051554, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 06'
  meter {  Fabricate(:easymeter_60051554) }
end

#sara strödel
Fabricator :mp_60051585, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 41'
  meter {  Fabricate(:easymeter_60051585) }
end

#hannelore voigt
Fabricator :mp_60051621, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '5', zip: 81476, city: 'München', state: 'Bayern') }
  name  'M 11'
  meter {  Fabricate(:easymeter_60051621) }
end

#roswitha weber
Fabricator :mp_60051565, from: :register do
  #address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'N 26'
  meter {  Fabricate(:easymeter_60051565) }
end

# #alexandra brunner
# Fabricator :mp_6005195, from: :register do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 27'
#  meter {  Fabricate(:easymeter_60051595) }
# end

# #sww ggmbh
# Fabricator :mp_6005195, from: :register do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 01'
#  meter {  Fabricate(:easymeter_60051595) }
# end

# #peter schmidt
# Fabricator :mp_6005195, from: :register do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'Übergabe'
#  meter {  Fabricate(:easymeter_60051595) }
# end

#abgrenzung pv
Fabricator :mp_60009484, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Abgrenzung PV'
  meter {  Fabricate(:easymeter_60009484) }
  mode        'out'
end

#bhkw1
Fabricator :mp_60138947, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'BHKW 1'
  meter {  Fabricate(:easymeter_60138947) }
  mode          'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
end

#bhkw2
Fabricator :mp_60138943, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'BHKW 2'
  meter {  Fabricate(:easymeter_60138943) }
  mode          'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
end

#pv
Fabricator :mp_1338000816, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name          'PV'
  meter {  Fabricate(:easymeter_1338000816) }
  mode          'out'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
end

#schule
Fabricator :mp_60009485, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Schule'
  meter {  Fabricate(:easymeter_60009485) }
end

#hst_mitte
Fabricator :mp_1338000818, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'HST Mitte'
  meter {  Fabricate(:easymeter_1338000818) }
end

#übergabe in
Fabricator :mp_1305004864, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Netzanschluss Bezug'
  meter {  Fabricate(:easymeter_1305004864) }
end

#übergabe out
Fabricator :mp_1305004864_out, from: :register do
  address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
  name  'Netzanschluss Einspeisung'
  meter {  Meter.where(manufacturer_product_serialnumber: 1305004864).first }
  mode        'out'
end

#virtueller Zählpunkt
Fabricator :mp_forstenried_erzeugung, from: :register do
  name  'Gesamterzeugung'
  virtual         true
  formula_parts   {[
                    Fabricate(:fp_plus, operand_id: Fabricate(:mp_60138947).id),
                    Fabricate(:fp_plus, operand_id: Fabricate(:mp_60138943).id),
                    Fabricate(:fp_minus, operand_id: Fabricate(:mp_1338000816).id)
                  ]}
  mode            'out'
end

#virtueller Zählpunkt
Fabricator :mp_forstenried_bezug, from: :register do
  name  'Gesamtverbrauch'
  virtual         true
end
