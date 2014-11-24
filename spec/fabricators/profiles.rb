# encoding: utf-8

Fabricator :profile do
  first_name  { Faker::Name.first_name }
  last_name   { Faker::Name.last_name }
  phone       { Faker::PhoneNumber.phone_number }
  terms       true
  i = 1
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{i+=1}.jpg")) }
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

Fabricator :profile_karin, from: :profile do
  first_name  'Karin'
  last_name   'Smith'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'karin.jpg')) }
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



Fabricator :profile_jangerdes, from: :profile do
  first_name  'Jan'
  last_name   'Gerdes'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian.jpg')) }
end

Fabricator :profile_christian_schuetze, from: :profile do
  first_name  'Christian'
  last_name   'Schütze'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian_schuetze.jpg')) }
end

Fabricator :profile_hans_dieter_hopf, from: :profile do
  first_name  'Hans Dieter'
  last_name   'Hopf'
end

Fabricator :profile_thomas_hopf, from: :profile do
  first_name  'Thomas'
  last_name   'Hopf'
end

Fabricator :profile_manuela_baier, from: :profile do
  first_name  'Manuela'
  last_name   'Baier'
end





