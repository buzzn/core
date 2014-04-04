# encoding: utf-8

Fabricator :user do
  email       { Faker::Internet.email }
  first_name  { Faker::Name.first_name }
  last_name   { Faker::Name.last_name }
  phone       { Faker::PhoneNumber.phone_number }
  terms       true
  password    'testtest'
  after_create { |user | user.confirm! }
end

Fabricator :admin, from: :user do
  email 'admin@buzzn.net'
end

Fabricator :felix, from: :user do
  email       'felix@buzzn.net'
  first_name  'Felix'
  last_name   'Faerber'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'felix.jpg')) }
end

Fabricator :justus, from: :user do
  email       'justus@buzzn.net'
  first_name  'Justus'
  last_name   'Schütze'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'justus.jpg')) }
end

Fabricator :danusch, from: :user do
  email       'danusch@buzzn.net'
  first_name  'Danusch'
  last_name   'Mahmoudi'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'danusch.jpg')) }
end

Fabricator :thomas, from: :user do
  email       'thomas@buzzn.net'
  first_name  'Thomas'
  last_name   'Theenhaus'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'thomas.jpg')) }
end

Fabricator :martina, from: :user do
  email       'martina@buzzn.net'
  first_name  'Martina'
  last_name   'Raschke'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'martina.jpg')) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  first_name  'Stefan'
  last_name   'Erbacher'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'stefan.jpg')) }
end

Fabricator :ole, from: :user do
  email       'ole@buzzn.net'
  first_name  'Ole'
  last_name   'Vörsmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'ole.jpg')) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  first_name  'Philipp'
  last_name   'Osswald'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'philipp.jpg')) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  first_name  'Christian'
  last_name   'Widmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'users', 'christian.jpg')) }
end

