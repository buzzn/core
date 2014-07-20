# encoding: utf-8

Fabricator :location do
  name            { Faker::Company.name }
  address         { Fabricate(:address) }
  metering_points { 1.times.map { Fabricate(:metering_point) } }
end

Fabricator :muehlenkamp, from: :location do
  name 'Mühlenkamp'
  address  { Fabricate(:address, street_name: 'mühlenkamp', street_number: '12d', zip: 22303, city: 'Hamburg', state: 'Hamburg') }
end

Fabricator :fichtenweg, from: :location do
  name              'Home of the Brave'
  address           { Fabricate(:address, street_name: 'Fichtenweg', street_number: '8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_points   {[
    Fabricate(:mp_z1),
    Fabricate(:mp_z2),
    Fabricate(:mp_z3),
    Fabricate(:mp_z4),
    Fabricate(:mp_z5)
  ]}
end



Fabricator :forstenrieder_weg, from: :location do
  name    'Buchenhain'
  image   { File.new(Rails.root.join('db', 'seed_assets', 'locations', 'forstenrieder_weg.jpg')) }
  address { Fabricate(:address, street_name: 'Forstenrieder Weg', street_number: '51', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_points {[
    Fabricate(:mp_stefans_bhkw)
  ]}
end



# location der pv alnalge von karin
Fabricator :gautinger_weg, from: :location do
  name    'Gautinger Weg'
  address  { Fabricate(:address, street_name: 'Gautinger Weg', street_number: '11', zip: 82065, city: 'Baierbrunn', state: 'Bayern') }
  metering_points {[
    Fabricate(:mp_pv_karin)
  ]}
end



