ActiveAdmin.register Contract::Tariff do

  index do
    id_column
    column :contract_id
    column :begin_date
    column :name
    actions
  end

end
