# encoding: utf-8

Fabricator :profile do
  user_name   { FFaker::Internet.user_name }
  phone       { FFaker::PhoneNumber.phone_number }
  terms       true
  i = 1
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{i+=1}.jpg")) }
  about_me    { FFaker::Lorem.sentence }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
end


Fabricator :profile_felix, from: :profile do
  user_name   'ffaerber'
  first_name  'Felix'
  last_name   'Faerber'
  website     'http://www.ffaerber.com'
  facebook    'https://www.facebook.com/ffaerber'
  twitter     'https://twitter.com/ffaerber'
  xing        'https://www.xing.com/profile/Felix_Faerber'
  linkedin    'https://www.linkedin.com/profile/view?id=61766404'
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


Fabricator :profile_dirk_mittelstaedt, from: :profile do
  first_name  'Dirk'
  last_name   'Mittelstaedt'
end

Fabricator :profile_manuel_dmoch, from: :profile do
  first_name  'Manuel'
  last_name   'Dmoch'
end

Fabricator :profile_sibo_ahrens, from: :profile do
  first_name  'Sibo'
  last_name   'Ahrens'
end

Fabricator :profile_nicolas_sadoni, from: :profile do
  first_name  'Nicolas'
  last_name   'Sadoni'
end

Fabricator :profile_josef_neu, from: :profile do
  first_name  'Josef'
  last_name   'Neu'
end

Fabricator :profile_elisabeth_christiansen, from: :profile do
  first_name  'Elisabeth'
  last_name   'Christiansen'
end

Fabricator :profile_florian_butz, from: :profile do
  first_name  'Florian'
  last_name   'Butz'
end

Fabricator :profile_ulrike_bez, from: :profile do
  first_name  'Ulrike'
  last_name   'Bez'
end

Fabricator :profile_rudolf_hassenstein, from: :profile do
  first_name  'Rudolf'
  last_name   'Hassenstein'
end


Fabricator :profile_andreas_schlafer, from: :profile do
  first_name  'Andreas'
  last_name   'Schlafer'
end

Fabricator :profile_luise_woerle, from: :profile do
  first_name  'Luise'
  last_name   'Woerle'
end

Fabricator :profile_peter_waechter, from: :profile do
  first_name  'Peter'
  last_name   'Waechter'
end

Fabricator :profile_sigrid_cycon, from: :profile do
  first_name  'Sigird'
  last_name   'Cycon'
end

Fabricator :profile_dietlind_klemm, from: :profile do
  first_name  'Dietlind'
  last_name   'Klemm'
end

Fabricator :profile_wilhelm_wagner, from: :profile do
  first_name  'Wilhelm'
  last_name   'Wagner'
end

Fabricator :profile_volker_letzner, from: :profile do
  first_name  'Volker'
  last_name   'Letzner'
end

Fabricator :profile_maria_mueller, from: :profile do
  first_name  'Maria'
  last_name   'Mueller'
end

Fabricator :profile_evang_pflege, from: :profile do
  first_name  'Evangelischer'
  last_name   'Pflegedienst'
end

Fabricator :profile_david_stadlmann, from: :profile do
  first_name  'David'
  last_name   'Stadlmann'
end

Fabricator :profile_doris_knaier, from: :profile do
  first_name  'Doris'
  last_name   'Knaier'
end

Fabricator :profile_sabine_dumler, from: :profile do
  first_name  'Sabine'
  last_name   'Dumler'
end

Fabricator :profile_uxtest, from: :profile do
  first_name 'Test'
  last_name  'User'
end






