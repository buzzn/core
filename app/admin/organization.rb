ActiveAdmin.register ContractingParty::Organization do

  menu :parent => "ContractingParty", :label => "Organization"

  index do
    id_column
    column :name
  end

end
