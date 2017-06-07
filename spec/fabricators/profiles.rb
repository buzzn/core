# encoding: utf-8

Fabricator :profile do
  first_name  { FFaker::Name.first_name.slice(0...30) }
  last_name   { FFaker::Name.last_name.slice(0...30) }
  user_name   { FFaker::Name.name.slice(0...30) }
  phone       { FFaker::PhoneNumber.phone_number }
  terms       true
  i = 0
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{((i+=1)%60) + 1}.jpg")) }
  about_me    { FFaker::Lorem.sentence }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
  created_at  { (rand*10).days.ago }
end


Fabricator :world_readable_profile, from: :profile do
  readable    'world'
end

Fabricator :community_readable_profile, from: :profile do
  readable    'community'
end

Fabricator :friends_readable_profile, from: :profile do
  readable    'friends'
end

Fabricator :profile_felix, from: :profile do
  user_name   'ffaerber'
  first_name  'Felix'
  last_name   'Faerber'
  website     'http://www.ffaerber.com'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'felix.jpg')) }
end


Fabricator :profile_ralf, from: :profile do
  user_name   'rschroeder'
  first_name  'Ralf'
  last_name   'Schroeder'
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

Fabricator :profile_eva, from: :profile do
  first_name  'Eva'
  last_name   'Klopp'
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

Fabricator :profile_pavel, from: :profile do
  first_name  'Pavel'
  last_name   'Gorbachev'
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

Fabricator :profile_geloeschter_benutzer, from: :profile do
  first_name  'Gelöschter'
  last_name   'Benutzer'
end

Fabricator :profile_mustafa, from: :profile do
  first_name  'Mustafa'
  last_name   'Akman'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "13.jpg")) }
end

Fabricator :profile_kristian, from: :profile do
  first_name  'Kristian'
  last_name   'Meier'
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


Fabricator :profile_uxtest, from: :profile do
  first_name 'Test'
  last_name  'User'
end
