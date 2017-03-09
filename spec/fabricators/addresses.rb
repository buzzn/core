# coding: utf-8
Fabricator :address do
  time_zone     'Berlin'
  city          'Berlin'
  street_name   'Lützowplatz'
  street_number '17'
  zip           10785
  country       'Germany'
  addition      'HH'
  created_at  { (rand*10).days.ago }
end

Fabricator :address_limmat, from: :address do
  time_zone     'Berlin'
  city          'München'
  street_name   'Limmatstraße'
  zip           81476
  country       'Germany'
  street_number '5'
  addition      ''
end


# don't use fake data as every address results in a google request for geolocation
