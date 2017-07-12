# encoding: utf-8

Fabricator :person do
  i = 0
  email       { "user#{i+=1}@gmail.de" }
  prefix      { Person::PREFIXES.sample }
  preferred_language { Person::PREFERRED_LANGUAGES.sample}
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
  i = 0
#  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{((i+=1)%60) + 1}.jpg")) }
end


Fabricator :person_felix, from: :person do
  user_name   'ffaerber'
  first_name  'Felix'
  last_name   'Faerber'
#  image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'felix.jpg')) }
end


Fabricator :person_ralf, from: :person do
  user_name   'rschroeder'
  first_name  'Ralf'
  last_name   'Schroeder'
end

Fabricator :person_justus, from: :person do
  first_name  'Justus'
  last_name   'Schütze'
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'justus.jpg')) }
end

Fabricator :person_danusch, from: :person do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'danusch.jpg')) }
end

Fabricator :person_thomas, from: :person do
  first_name  'Thomas'
  last_name   'Theenhaus'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'thomas.jpg')) }
end

Fabricator :person_eva, from: :person do
  first_name  'Eva'
  last_name   'Klopp'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'martina.jpg')) }
end

Fabricator :person_stefan, from: :person do
  first_name  'Stefan'
  last_name   'Erbacher'
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'stefan.jpg')) }
end

Fabricator :person_karin, from: :person do
  first_name  'Karin'
  last_name   'Smith'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'karin.jpg')) }
end

Fabricator :person_pavel, from: :person do
  first_name  'Pavel'
  last_name   'Gorbachev'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'ole.jpg')) }
end

Fabricator :person_philipp, from: :person do
  first_name  'Philipp'
  last_name   'Osswald'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'philipp.jpg')) }
end

Fabricator :person_christian, from: :person do
  first_name  'Christian'
  last_name   'Widmann'
#  image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian.jpg')) }
end

Fabricator :person_mustafa, from: :person do
  first_name  'Mustafa'
  last_name   'Akman'
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', "13.jpg")) }
end

Fabricator :person_kristian, from: :person do
  first_name  'Kristian'
  last_name   'Meier'
end



Fabricator :person_jangerdes, from: :person do
  first_name  'Jan'
  last_name   'Gerdes'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian.jpg')) }
end

Fabricator :person_christian_schuetze, from: :person do
  first_name  'Christian'
  last_name   'Schütze'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian_schuetze.jpg')) }
end


Fabricator :person_uxtest, from: :person do
  first_name 'Test'
  last_name  'User'
end
