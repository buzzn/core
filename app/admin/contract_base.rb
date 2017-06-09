ActiveAdmin.register Contract::Base do

  index do
    id_column
    column :name
    column :contract_number
    column :customer_id
    column :customer_type
    column :begin_date
    column :status
    actions
  end

end
