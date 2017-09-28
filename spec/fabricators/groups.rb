Fabricator :new_localpool, class_name: "Group::Localpool" do
  name        { sequence { |i| "Localpool #{i}" } }
  description { |attrs| "#{attrs[:name]} description" }
end
