Fabricator :group do
  name        { Faker::Company.name }
  description { Faker::Lorem.paragraphs.join('-') }
end


Fabricator :group_hof_butenland, from: :group do
  name        'Hof Butenland'
  assets      { [
                 Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'hof_butenland.jpg')))
                 ] }
end


Fabricator :group_home_of_the_brave, from: :group do
  name        'Home of the Brave'
  assets      { [
                 Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'home_of_the_brave.jpg')))
                 ] }
end

Fabricator :group_karins_pv_strom, from: :group do
  name        'Karins PV Strom'
  description { "Diese Gruppe ist offen für alle, die gerne meinen selbstgemachten PV-Strom von meiner Scheune beziehen möchten." }
  assets      { [
                 Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')))
                 ] }
end


