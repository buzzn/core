class CreateDistributionSystemOperatorContracts < ActiveRecord::Migration
  def change
    create_table :distribution_system_operator_contracts do |t|

      t.string :name
      t.string :status
      t.decimal :price_cents, precision: 16, default: 0
      t.string :bdew_code
      t.string :edifact_email
      t.string :contact_name
      t.string :contact_email

      t.integer :metering_point_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :distribution_system_operator_contracts, :organization_id
    add_index :distribution_system_operator_contracts, :metering_point_id, name: 'index_dso_contracts_on_metering_point_id'
  end
end
