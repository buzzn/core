# encoding: utf-8

Fabricator :location do
  address         { Fabricate(:address) }
  metering_point  { Fabricate(:metering_point) }
end

# felix
Fabricator :belfortstr10, from: :location do
  address  { Fabricate(:address, street_name: 'Belfortstraße', street_number: '10', zip: 81667, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_belfortstr10) }
end
Fabricator :urbanstr88, from: :location do
  address  { Fabricate(:address, street_name: 'Urbanstr', street_number: '88', zip: 81667, city: 'Berlin', state: 'Berlin') }
  metering_point { Fabricate(:mp_urbanstr88) }
end


# justus
Fabricator :fichtenweg8, from: :location do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_point { }
end

# christian
Fabricator :fichtenweg10, from: :location do
  address  { Fabricate(:address, street_name: 'Fichtenweg', street_number: '10', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_point { Fabricate(:mp_cs_1) }
end





Fabricator :forstenrieder_weg, from: :location do
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_point { Fabricate(:mp_stefans_bhkw) }
end



# location der pv alnalge von karin
Fabricator :gautinger_weg, from: :location do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_point { Fabricate(:mp_pv_karin) }
end




# hof_butenland
Fabricator :niensweg, from: :location do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  metering_point { Fabricate(:mp_hof_butenland_wind) }
end



Fabricator :location_hopf, from: :location do
  address  { Fabricate(:address_hopf) } # TODO no real address
  metering_point { Fabricate(:mp_60118470) }
end

Fabricator :location_thomas_hopf, from: :location do
  address  { Fabricate(:address_hopf) } # TODO no real address
  metering_point { Fabricate(:mp_60009272) }
end

Fabricator :location_manuela_baier, from: :location do
  address  { Fabricate(:address_hopf) } # TODO no real address
  metering_point { Fabricate(:mp_60009348) }
end



Fabricator :roentgenstrasse11, from: :location do
  address        { Fabricate(:address, street_name: 'Röntgenstrasse', street_number: '11', zip: 86199, city: 'Augsburg', state: 'Bayern') }
  metering_point { Fabricate(:mp_60138988) }
end

Fabricator :location_philipp, from: :location do
  address         { Fabricate(:address) } #TODO real address
  metering_point  { Fabricate(:mp_60009269) }
end




Fabricator :location_dirk_mittelstaedt, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009416)}
end

Fabricator :location_manuel_dmoch, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009419)}
end

Fabricator :location_sibo_ahrens, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009415)}
end
Fabricator :location_nicolas_sadoni, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009418)}
end
Fabricator :location_josef_neu, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009411)}
end
Fabricator :location_elisabeth_christiansen, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009410)}
end
Fabricator :location_florian_butz, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009407)}
end
Fabricator :location_ulrike_bez, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009409)}
end
Fabricator :location_rudolf_hassenstein, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009435)}
end
Fabricator :location_wagnis4, from: :location do
  address        { Fabricate(:address, street_name: 'Petra-Kelly-Straße', street_number: '29', zip: 80797, city: 'München', state: 'Bayern') }
  metering_point { Fabricate(:mp_60009420)}
end









