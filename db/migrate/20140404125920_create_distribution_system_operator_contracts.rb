class CreateDistributionSystemOperatorContracts < ActiveRecord::Migration
  def change
    create_table :distribution_system_operator_contracts do |t|

      t.string :customer_number
      t.string :contract_number

      t.integer :distribution_system_operator_id
      t.integer :contract_id

      t.timestamps
    end
  end
end
