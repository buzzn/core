# encoding: utf-8

Fabricator :profile do
  first_name  { Faker::Name.first_name }
  last_name   { Faker::Name.last_name }
  phone       { Faker::PhoneNumber.phone_number }
end


Fabricator :profile_felix, from: :profile do
  first_name  'Felix'
  last_name   'Faerber'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'felix.jpg')) }
end

Fabricator :profile_justus, from: :profile do
  first_name  'Justus'
  last_name   'Schütze'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'justus.jpg')) }
end

Fabricator :profile_danusch, from: :profile do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'danusch.jpg')) }
end

Fabricator :profile_thomas, from: :profile do
  first_name  'Thomas'
  last_name   'Theenhaus'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'thomas.jpg')) }
end

Fabricator :profile_martina, from: :profile do
  first_name  'Martina'
  last_name   'Raschke'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'martina.jpg')) }
end

Fabricator :profile_stefan, from: :profile do
  first_name  'Stefan'
  last_name   'Erbacher'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'stefan.jpg')) }
end

Fabricator :profile_ole, from: :profile do
  first_name  'Ole'
  last_name   'Vörsmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'ole.jpg')) }
end

Fabricator :profile_philipp, from: :profile do
  first_name  'Philipp'
  last_name   'Osswald'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'philipp.jpg')) }
end

Fabricator :profile_christian, from: :profile do
  first_name  'Christian'
  last_name   'Widmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian.jpg')) }
end

