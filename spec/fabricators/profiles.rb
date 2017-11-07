
Fabricator :profile do
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  user_name   { FFaker::Name.name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
  terms       true
  i = 0
  about_me    { FFaker::Lorem.sentence }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
  created_at  { (rand*10).days.ago }
end


Fabricator :profile_felix, from: :profile do
  user_name   'ffaerber'
  first_name  'Felix'
  last_name   'Faerber'
  website     'http://www.ffaerber.com'
end


Fabricator :profile_ralf, from: :profile do
  user_name   'rschroeder'
  first_name  'Ralf'
  last_name   'Schroeder'
end

Fabricator :profile_justus, from: :profile do
  first_name  'Justus'
  last_name   'Schütze'
end

Fabricator :profile_danusch, from: :profile do
  first_name  'Danusch'
  last_name   'Mahmoudi'
end

Fabricator :profile_thomas, from: :profile do
  first_name  'Thomas'
  last_name   'Theenhaus'
end

Fabricator :profile_eva, from: :profile do
  first_name  'Eva'
  last_name   'Klopp'
end

Fabricator :profile_stefan, from: :profile do
  first_name  'Stefan'
  last_name   'Erbacher'
end

Fabricator :profile_karin, from: :profile do
  first_name  'Karin'
  last_name   'Smith'
end

Fabricator :profile_pavel, from: :profile do
  first_name  'Pavel'
  last_name   'Gorbachev'
end

Fabricator :profile_philipp, from: :profile do
  first_name  'Philipp'
  last_name   'Osswald'
end

Fabricator :profile_christian, from: :profile do
  first_name  'Christian'
  last_name   'Widmann'
end

Fabricator :profile_mustafa, from: :profile do
  first_name  'Mustafa'
  last_name   'Akman'
end

Fabricator :profile_kristian, from: :profile do
  first_name  'Kristian'
  last_name   'Meier'
end

Fabricator :profile_jangerdes, from: :profile do
  first_name  'Jan'
  last_name   'Gerdes'
end

Fabricator :profile_christian_schuetze, from: :profile do
  first_name  'Christian'
  last_name   'Schütze'
end

Fabricator :profile_uxtest, from: :profile do
  first_name 'Test'
  last_name  'User'
end
