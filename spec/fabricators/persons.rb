
Fabricator :person do
  i = 0
  email       { "user.#{i+=1}@buzzn.net" }
  prefix      { Person::PREFIXES.sample }
  title       { ([nil] + Person::TITLES).sample }
  preferred_language { Person::PREFERRED_LANGUAGES.sample}
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
  image       { nr = ((i += 1) % 30 ) + 1; File.new(Rails.root.join("spec/fixture_files/profiles/#{nr}.jpg")) }
end


Fabricator :person_felix, from: :person do
  first_name  'Felix'
  last_name   'Faerber'
  title       nil
#  image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'felix.jpg')) }
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
 # image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'justus.jpg')) }
end

Fabricator :person_danusch, from: :person do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'danusch.jpg')) }
end

Fabricator :person_thomas, from: :person do
  first_name  'Thomas'
  last_name   'Theenhaus'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'thomas.jpg')) }
end

Fabricator :person_eva, from: :person do
  first_name  'Eva'
  last_name   'Klopp'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'martina.jpg')) }
end

Fabricator :person_stefan, from: :person do
  first_name  'Stefan'
  last_name   'Erbacher'
  title       nil
 # image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'stefan.jpg')) }
end

Fabricator :person_karin, from: :person do
  first_name  'Karin'
  last_name   'Smith'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'karin.jpg')) }
end

Fabricator :person_pavel, from: :person do
  first_name  'Pavel'
  last_name   'Gorbachev'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'ole.jpg')) }
end

Fabricator :person_philipp, from: :person do
  first_name  'Philipp'
  last_name   'Osswald'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'philipp.jpg')) }
end

Fabricator :person_christian, from: :person do
  first_name  'Christian'
  last_name   'Widmann'
  title       nil
#  image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'christian.jpg')) }
end

Fabricator :person_mustafa, from: :person do
  first_name  'Mustafa'
  last_name   'Akman'
  title       nil
 # image       { File.new(Rails.root.join('spec/fixture_files', 'persons', "13.jpg")) }
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
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'christian.jpg')) }
end

Fabricator :person_christian_schuetze, from: :person do
  first_name  'Christian'
  last_name   'Schütze'
  title       nil
  #image       { File.new(Rails.root.join('spec/fixture_files', 'persons', 'christian_schuetze.jpg')) }
end


Fabricator :person_uxtest, from: :person do
  first_name 'Test'
  last_name  'User'
  title      'Prof. Dr.'
end
