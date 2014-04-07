class CreateContractingParties < ActiveRecord::Migration
  def change
    create_table :contracting_parties do |t|

      t.string :legal_entity

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :contracting_parties, :metering_point_id
  end
end
