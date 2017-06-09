ActiveAdmin.register Billing do

  index do
    id_column
    column :billing_cycle
    column :status
    column :localpool_power_taker_contract_id
    column :invoice_number
    actions
  end

end
