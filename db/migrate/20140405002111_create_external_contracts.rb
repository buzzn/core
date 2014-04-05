class CreateExternalContracts < ActiveRecord::Migration
  def change
    create_table :external_contracts do |t|
      
      t.string :mode
      t.string :customer_number
      t.string :contract_number

      t.integer :external_contractable_id
      t.string  :external_contractable_type

      t.timestamps
    end
  end
end
