

Fabricator :metering_point do
  name  'Wohnung'
  i = 1
  uid         {"DE001068825151000000000000#{2677114 + (i += 1)}"}
  register   { Fabricate(:register_in) }
  #contracts   { [ Fabricate(:electricity_supplier_contract)] }
end


Fabricator :mp_z1a, from: :metering_point do
  name  'Netzanschluss Bezug'
end

Fabricator :mp_z1b, from: :metering_point do
  name  'Netzanschluss Einspeisung'
  register   { Fabricate(:register_out) }
end


Fabricator :mp_z2, from: :metering_point do
  name  'PV'
  register   { Fabricate(:register_out) }
  meter       { Fabricate(:easymeter_60051599) }
end



Fabricator :mp_z3, from: :metering_point do
  name  'Ladestation'
  meter       { Fabricate(:easymeter_60051559) }
end


Fabricator :mp_z4, from: :metering_point do
  name  'BHKW'
  register   { Fabricate(:register_out) }
  meter       { Fabricate(:easymeter_60051560) }
end



Fabricator :mp_z5, from: :metering_point do
  name  'Abgrenzung'
  register   { Fabricate(:register_out) }
  meter       { Fabricate(:easymeter_60051600) }
end



#felix berlin
Fabricator :mp_urbanstr88, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Urbanstr', street_number: '88', zip: 81667, city: 'Berlin', state: 'Berlin') }
  name  'Wohnung'
end




# karins pv anlage
Fabricator :mp_pv_karin, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'PV Scheune'
  register   { Fabricate(:register_out) }
  meter       { Fabricate(:easymeter_60051431) }
end




# stefans bhkw anlage
Fabricator :mp_stefans_bhkw, from: :metering_point do
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  name  'BHKW'
  register   { Fabricate(:register_out) }
end




# hof butenland windanlage
Fabricator :mp_hof_butenland_wind, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  name  'Windanlage'
  register   { Fabricate(:register_out) }
end



# christian_schuetze verbrauch
Fabricator :mp_cs_1, from: :metering_point do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  name  'Wohnung'
  meter { Fabricate(:easymeter_1124001747) }
end



# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :mp_60138988, from: :metering_point do
  address        { Fabricate(:address, street_name: 'Röntgenstrasse', street_number: '11', zip: 86199, city: 'Augsburg', state: 'Bayern') }
  name  'Wohnung'
  meter { Fabricate(:easymeter_60138988) }
end


# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :mp_60009269, from: :metering_point do
  name  'Wohnung'
  meter { Fabricate(:easymeter_60009269) }
end

# Nr. 60176745 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :mp_60176745, from: :metering_point do
  name  'Wohnung'
  meter { Fabricate(:easymeter_60176745) }
end






# Z1  Nr. 60118470 für Hans-Dieter Hopf übergame  (Zweirichtungszähler)
Fabricator :mp_60118470, from: :metering_point do
  name  'Keller'
  register   { Fabricate(:register_out) }
  meter { Fabricate(:easymeter_60118470) }
end

# Z2  Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :mp_60009316, from: :metering_point do
  name  'Keller'
  meter { Fabricate(:easymeter_60009316) }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :mp_60009272, from: :metering_point do
  name  'Wohnung'
  meter { Fabricate(:easymeter_60009272) }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :mp_60009348, from: :metering_point do
  name  'Restaurant Beier'
  meter          { Fabricate(:easymeter_60009348) }
end

# Wohnung Hr. Hopf ("ZN3") ist ungezählt kann aber berechnet werden
Fabricator :mp_hans_dieter_hopf, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:virtual_meter_hopf) }
end




#Wagnis 4 - West Wohnung 02 - Dirk Mittelstaedt
Fabricator :mp_60009416, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009416) }
end

#Wagnis 4 - West Wohnung 03 - Manuel Dmoch
Fabricator :mp_60009419, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009419) }
end

#Wagnis 4 - West Wohnung 04 - Sibo Ahrens
Fabricator :mp_60009415, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009415) }
end

#Wagnis 4 - West Wohnung 05 - Nicolas Sadoni
Fabricator :mp_60009418, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009418) }
end

#Wagnis 4 - West Wohnung 11 - Josef Neu
Fabricator :mp_60009411, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009411) }
end

#Wagnis 4 - West Wohnung 13 - Elisabeth Christiansen
Fabricator :mp_60009410, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009410) }
end

#Wagnis 4 - West Wohnung 12 - Florian Butz
Fabricator :mp_60009407, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009407) }
end

#Wagnis 4 - West Wohnung 15 - Ulrike Bez
Fabricator :mp_60009409, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009409) }
end

#Wagnis 4 - West Wohnung 15 - Rudolf Hassenstein
Fabricator :mp_60009435, from: :metering_point do
  name  'Wohnung'
  meter          { Fabricate(:easymeter_60009435) }
end

#Wagnis 4 - Allgemeinstrom Haus West
Fabricator :mp_60009420, from: :metering_point do
  name  'Allgemeinstrom Haus West'
  meter          { Fabricate(:easymeter_60009420) }
end

#Wagnis 4 - PV
Fabricator :mp_60118460, from: :metering_point do
  name  'PV'
  meter          { Fabricate(:easymeter_60118460) }
  register      { Fabricate(:register_out) }
end




#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :mp_60009386, from: :metering_point do
  name  'Allgemeinstrom Haus Nord'
  meter          { Fabricate(:easymeter_60009386) }
end

#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :mp_60009445, from: :metering_point do
  name  'Allgemeinstrom Haus Nord'
  meter          { Fabricate(:easymeter_60009445) }
end

#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :mp_60009446, from: :metering_point do
  name  'Gäste Haus Ost 1+2'
  meter          { Fabricate(:easymeter_60009446) }
end

#Wagnis 4 - Laden EG
Fabricator :mp_60009390, from: :metering_point do
  name  'Laden EG'
  meter          { Fabricate(:easymeter_60009390) }
end

#Wagnis 4 - Nord Wohnung 01
Fabricator :mp_60009387, from: :metering_point do
  name  'Nord Wohnung 01'
  meter          { Fabricate(:easymeter_60009387) }
end

#Wagnis 4 - Nord Wohnung 10
Fabricator :mp_60009438, from: :metering_point do
  name  'Nord Wohnung 10'
  meter          { Fabricate(:easymeter_60009438) }
end

#Wagnis 4 - Nord Wohnung 12
Fabricator :mp_60009440, from: :metering_point do
  name  'Nord Wohnung 12'
  meter          { Fabricate(:easymeter_60009440) }
end

#Wagnis 4 - Nord Wohnung 15
Fabricator :mp_60009404, from: :metering_point do
  name  'Nord Wohnung 15'
  meter          { Fabricate(:easymeter_60009404) }
end

#Wagnis 4 - Nord Wohnung 17
Fabricator :mp_60009405, from: :metering_point do
  name  'Nord Wohnung 17'
  meter          { Fabricate(:easymeter_60009405) }
end

#Wagnis 4 - Nord Wohnung 18
Fabricator :mp_60009422, from: :metering_point do
  name  'Nord Wohnung 18'
  meter          { Fabricate(:easymeter_60009422) }
end

#Wagnis 4 - Nord Wohnung 19
Fabricator :mp_60009425, from: :metering_point do
  name  'Nord Wohnung 19'
  meter          { Fabricate(:easymeter_60009425) }
end

#Wagnis 4 - Nord Wohnung 20
Fabricator :mp_60009402, from: :metering_point do
  name  'Nord Wohnung 20'
  meter          { Fabricate(:easymeter_60009402) }
end

#Wagnis 4 - Ost 03
Fabricator :mp_60009429, from: :metering_point do
  name  'Ost 03'
  meter          { Fabricate(:easymeter_60009429) }
end

#Wagnis 4 - Ost Wohnung 12
Fabricator :mp_60009393, from: :metering_point do
  name  'Ost Wohnung 12'
  meter          { Fabricate(:easymeter_60009393) }
end

#Wagnis 4 - Ost Wohnung 13
Fabricator :mp_60009442, from: :metering_point do
  name  'Ost Wohnung 13'
  meter          { Fabricate(:easymeter_60009442) }
end

#Wagnis 4 - Ost Wohnung 15
Fabricator :mp_60009441, from: :metering_point do
  name  'Ost Wohnung 15'
  meter          { Fabricate(:easymeter_60009441) }
end

#Wagnis 4 - Übergabe
Fabricator :mp_60118484, from: :metering_point do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  name  'Übergabe'
  meter          { Fabricate(:easymeter_60118484) }
  register   { Fabricate(:register_in) }
end




#Pickel Wasserkraft
Fabricator :mp_60051562, from: :metering_point do
  name  'Wasserkraft'
  meter          { Fabricate(:easymeter_60051562) }
end













