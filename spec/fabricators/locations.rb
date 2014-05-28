# encoding: utf-8

Fabricator :location do
  address         { Fabricate(:address) }
  metering_points { 1.times.map { Fabricate(:metering_point) } }
end

Fabricator :location_muehlenkamp, from: :location do
  address  { Fabricate(:address, street: 'mühlenkamp 12d', zip: 22303, city: 'Hamburg', state: 'Hamburg') }
end

Fabricator :location_fichtenweg, from: :location do
  address           { Fabricate(:address, street: 'Fichtenweg 8', zip: 82515, city: 'Wolfratshausen', state: 'Bayern') }
  metering_points   {[
    Fabricate(:mp_z1),
    Fabricate(:mp_z2),
    Fabricate(:mp_z3),
    Fabricate(:mp_z4)
  ]}
end
