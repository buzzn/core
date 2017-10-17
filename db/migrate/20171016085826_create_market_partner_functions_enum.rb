class CreateMarketPartnerFunctionsEnum < ActiveRecord::Migration
  def up
    create_enum :market_partner_function, *OrganizationMarketFunction.functions.keys
    remove_column :organization_market_functions, :function
    add_column :organization_market_functions, :function, :market_partner_function, index: true
  end

  def down
    remove_column :organization_market_functions, :function
    add_column :organization_market_functions, :function, :integer, index: true
    drop_enum :market_partner_function
  end
end
