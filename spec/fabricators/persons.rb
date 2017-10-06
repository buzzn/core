# encoding: utf-8

Fabricator :person do
  i = 0
  email       { "user.#{i+=1}@buzzn.net" }
  prefix      { Person::PREFIXES.sample }
  title       { ([nil] + Person::TITLES).sample }
  preferred_language { Person::PREFERRED_LANGUAGES.sample}
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{((i+=1)%60) + 1}.jpg")) }
end


Fabricator :person_felix, from: :person do
  first_name  'Felix'
  last_name   'Faerber'
  title       nil
#  image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'felix.jpg')) }
end


Fabricator :person_ralf, from: :person do
  first_name  'Ralf'
  last_name   'Schroeder'
  title       nil
end

Fabricator :person_justus, from: :person do
  first_name  'Justus'
  last_name   'Schütze'
  title       nil
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'justus.jpg')) }
end

Fabricator :person_danusch, from: :person do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'danusch.jpg')) }
end

Fabricator :person_thomas, from: :person do
  first_name  'Thomas'
  last_name   'Theenhaus'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'thomas.jpg')) }
end

Fabricator :person_eva, from: :person do
  first_name  'Eva'
  last_name   'Klopp'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'martina.jpg')) }
end

Fabricator :person_stefan, from: :person do
  first_name  'Stefan'
  last_name   'Erbacher'
  title       nil
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'stefan.jpg')) }
end

Fabricator :person_karin, from: :person do
  first_name  'Karin'
  last_name   'Smith'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'karin.jpg')) }
end

Fabricator :person_pavel, from: :person do
  first_name  'Pavel'
  last_name   'Gorbachev'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'ole.jpg')) }
end

Fabricator :person_philipp, from: :person do
  first_name  'Philipp'
  last_name   'Osswald'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'philipp.jpg')) }
end

Fabricator :person_christian, from: :person do
  first_name  'Christian'
  last_name   'Widmann'
  title       nil
#  image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian.jpg')) }
end

Fabricator :person_mustafa, from: :person do
  first_name  'Mustafa'
  last_name   'Akman'
  title       nil
 # image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', "13.jpg")) }
end

Fabricator :person_kristian, from: :person do
  first_name  'Christian'
  last_name   'Meier'
  title       nil
end



Fabricator :person_jangerdes, from: :person do
  first_name  'Jan'
  last_name   'Gerdes'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian.jpg')) }
end

Fabricator :person_christian_schuetze, from: :person do
  first_name  'Christian'
  last_name   'Schütze'
  title       nil
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'persons', 'christian_schuetze.jpg')) }
end


Fabricator :person_uxtest, from: :person do
  first_name 'Test'
  last_name  'User'
  title      'Prof. Dr.'
end
