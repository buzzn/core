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


# don't use fake data
