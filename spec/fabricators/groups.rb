Fabricator :group do
  name        { Faker::Company.name }
  description { Faker::Lorem.paragraphs.join('-') }
end


Fabricator :group_hof_butenland, from: :group do
  name        'Hof Butenland'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'hof_butenland.jpg')) }
end


Fabricator :group_home_of_the_brave, from: :group do
  name        'Home of the Brave'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'home_of_the_brave.jpg')) }
end

Fabricator :group_karins_pv_strom, from: :group do
  name        'Karins PV Strom'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'pv_karin.jpg')) }
  description { "Diese Gruppe ist offen für alle, die gerne meinen selbstgemachten PV-Strom von meiner Scheune beziehen möchten." }
end


