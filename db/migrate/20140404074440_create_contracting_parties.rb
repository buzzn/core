class CreateContractingParties < ActiveRecord::Migration
  def change
    create_table :contracting_parties do |t|

      t.string :legal_entity

      t.integer :user_id

      t.timestamps
    end
    add_index :contracting_parties, :user_id
  end
end
