Fabricator :group do
  name        { Faker::Company.name }
  description { Faker::Lorem.paragraphs.join('-') }
end


Fabricator :group_hof_butenland, from: :group do
  name        'Hof Butenland'
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'hof_butenland', 'logo.jpg')) }
end


Fabricator :group_hopf, from: :group do
  name                              'Hopf'
  metering_point_operator_contract  { Fabricate(:mspc_buzzn_metering) }
  servicing_contract                { Fabricate(:servicing_contract) }
end

Fabricator :group_home_of_the_brave, from: :group do
  name        'Home of the Brave'
end

Fabricator :group_karins_pv_strom, from: :group do
  name        'Karins PV Strom'
  description { "Diese Gruppe ist offen für alle, die gerne meinen selbstgemachten PV-Strom von meiner Scheune beziehen möchten." }
end

Fabricator :group_wagnis4, from: :group do
  name        'Wagnis 4'
  description { "Dies ist der Localpool von Wagnis 4." }
  servicing_contract { Fabricate(:servicing_contract) }
  logo      { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'logo.png'))}
  image     { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'wagnis4', 'image.png')) }
end



