Fabricator :address do
  city          'Berlin'
  street        'Lützowplatz 17, HH'
  zip           '10785'
  country       'DE'
  state         'DE_BE'
end

Fabricator :address_limmat_5, from: :address do
  city          'München'
  street        'Limmatstraße 5'
  zip           '81476'
  country       'DE'
end

Fabricator :address_limmat_3, from: :address_limmat_5 do
  street        'Limmatstraße 3'
end

Fabricator :address_limmat_7, from: :address_limmat_5 do
  street        'Limmatstraße 7'
end

Fabricator :address_luetzowplatz, from: :address do
  zip    '81667'
  street 'Lützowplatz 123'
end

Fabricator :address_sulz, from: :address do
  street  'Sulz 2'
  zip     '82380'
  city    'Peißenberg'
  state   'DE_BY'
end
  
# don't use fake data as every address results in a google request for geolocation
