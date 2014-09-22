# encoding: utf-8

Fabricator :location do
  address         { Fabricate(:address) }
  metering_points { 1.times.map { Fabricate(:metering_point) } }
end

Fabricator :muehlenkamp, from: :location do
  address  { Fabricate(:address, street_name: 'mühlenkamp', street_number: '12d', zip: 22303, city: 'Hamburg', state: 'Hamburg') }
end



Fabricator :fichtenweg8, from: :location do
  address           { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_points   {[
    Fabricate(:mp_z1),
    Fabricate(:mp_z2),
    Fabricate(:mp_z3),
    Fabricate(:mp_z4),
    Fabricate(:mp_z5)
  ]}
end


Fabricator :fichtenweg10, from: :location do
  address           { Fabricate(:address, street_name: 'Fichtenweg', street_number: '10', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_points   {[
    Fabricate(:mp_cs_1)
  ]}
end





Fabricator :forstenrieder_weg, from: :location do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'forstenrieder_weg.jpg')))
                                    ] }

  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_points {[
    Fabricate(:mp_stefans_bhkw)
  ]}
end



# location der pv alnalge von karin
Fabricator :gautinger_weg, from: :location do
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_points {[
    Fabricate(:mp_pv_karin)
  ]}
end




# hof_butenland
Fabricator :niensweg, from: :location do
  address  { Fabricate(:address, street_name: 'Niensweg', street_number: '1', zip: 26969, city: 'Butjadingen', state: 'Niedersachsen') }
  metering_points {[
    Fabricate(:mp_hof_butenland_wind)
  ]}
end



Fabricator :location_hopf, from: :location do
  address  { Fabricate(:address) } # TODO
  metering_points {[
    Fabricate(:mp_60118470),
    Fabricate(:mp_60009316),
    Fabricate(:mp_60009272),
    Fabricate(:mp_60009348),
    Fabricate(:mp_hans_dieter_hopf)
  ]}
end









