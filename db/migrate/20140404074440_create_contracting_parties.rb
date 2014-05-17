class CreateContractingParties < ActiveRecord::Migration
  def change
    create_table :contracting_parties do |t|

      t.string :legal_entity

      t.integer :sales_tax_number
      t.float   :tax_rate
      t.integer :tax_number

      t.integer :organization_id
      t.integer :metering_point_id
      t.integer :user_id

      t.timestamps
    end
    add_index :contracting_parties, :metering_point_id
  end
end
