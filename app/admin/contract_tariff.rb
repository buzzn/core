ActiveAdmin.register Contract::Tariff do

  menu :parent => "Contract", :label => "Tariff"

  index do
    id_column
    column :contract_id
    column :begin_date
    column :name
    actions
  end

end
