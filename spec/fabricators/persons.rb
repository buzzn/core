
Fabricator :person do
  i = 0
  email       { "user.#{i+=1}@buzzn.net" }
  prefix      { Person::PREFIXES.sample }
  title       { ([nil] + Person::TITLES).sample }
  preferred_language { Person::PREFERRED_LANGUAGES.sample}
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
end


Fabricator :person_felix, from: :person do
  first_name  'Felix'
  last_name   'Faerber'
  title       nil
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
end

Fabricator :person_danusch, from: :person do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  title       nil
end

Fabricator :person_thomas, from: :person do
  first_name  'Thomas'
  last_name   'Theenhaus'
  title       nil
end

Fabricator :person_eva, from: :person do
  first_name  'Eva'
  last_name   'Klopp'
  title       nil
end

Fabricator :person_stefan, from: :person do
  first_name  'Stefan'
  last_name   'Erbacher'
  title       nil
end

Fabricator :person_karin, from: :person do
  first_name  'Karin'
  last_name   'Smith'
  title       nil
end

Fabricator :person_pavel, from: :person do
  first_name  'Pavel'
  last_name   'Gorbachev'
  title       nil
end

Fabricator :person_philipp, from: :person do
  first_name  'Philipp'
  last_name   'Osswald'
  title       nil
end

Fabricator :person_christian, from: :person do
  first_name  'Christian'
  last_name   'Widmann'
  title       nil
end

Fabricator :person_mustafa, from: :person do
  first_name  'Mustafa'
  last_name   'Akman'
  title       nil
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
end

Fabricator :person_christian_schuetze, from: :person do
  first_name  'Christian'
  last_name   'Schütze'
  title       nil
end


Fabricator :person_uxtest, from: :person do
  first_name 'Test'
  last_name  'User'
  title      'Prof. Dr.'
end
