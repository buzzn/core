ActiveAdmin.register Contract::Payment do

  menu :parent => "Contract", :label => "Payment"

  index do
    id_column
    column :contract_id
    column :begin_date
    column :cycle
    column :source
    actions
  end

end
