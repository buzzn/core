Fabricator :new_address, class_name: "Address" do
  street  "Musterstraße 1"
  city    "Musterstadt"
  zip     "12345"
  state   Address.states[:DE_BE]
  country Address.countries[:germany]
end
