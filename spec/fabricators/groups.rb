Fabricator :group do
  name        { FFaker::Company.name }
  description { FFaker::Lorem.paragraphs.join('-') }
  readable    'world'
end


Fabricator :group_hof_butenland, from: :group do
  name        'Hof Butenland'
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'hof_butenland', 'logo.jpg')) }
  contracts { [] }
end


Fabricator :group_hopf, from: :group do
  name 'Hopf'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
end

Fabricator :group_home_of_the_brave, from: :group do
  name        'Home of the Brave'
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
end

Fabricator :group_karins_pv_strom, from: :group do
  name        'Karins PV Strom'
  description { "Diese Gruppe ist offen für alle, die gerne meinen selbstgemachten PV-Strom von meiner Scheune beziehen möchten." }
end

Fabricator :group_wagnis4, from: :group do
  name        'Wagnis 4'
  website     'http://www.wagnis.org/wagnis/wohnprojekte/wagnis-4.html'
  description { "Dies ist der Localpool von Wagnis 4." }
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'logo.png'))}
  image     { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'image.png')) }
end


Fabricator :group_forstenried, from: :group do
  name        'Mehrgenerationenplatz Forstenried'
  website     'http://www.energie.wogeno.de/'
  description { "Dies ist der Localpool des Mehrgenerationenplatzes Forstenried der Freien Waldorfschule München Südwest und Wogeno München eG." }
  contracts { [Fabricate(:mpoc_buzzn_metering)] }
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'schule_logo_wogeno.jpg'))}
  image     { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'forstenried', 'Wogeno_app.jpg')) }
end


