Fabricator :new_person, class_name: "Person" do
  first_name          "Uwe"
  last_name           "User"
  email               "dev+uweuser@buzzn.net"
  phone               "0815 123 456 789"
  prefix              Person.prefixes[:male]
  preferred_language  Person.preferred_languages[:german]
  address             { Fabricate(:new_address) }
end
