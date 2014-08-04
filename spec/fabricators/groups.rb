Fabricator :group do
  name        { Faker::Company.name }
  description { Faker::Lorem.paragraphs.join('-') }
end


Fabricator :group_hof_butenland, from: :group do
  name        'Hof Butenland'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'groups', 'hof_butenland.jpg')) }
  description { Faker::Lorem.paragraphs.join('-') }
end



