class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|

      t.string  :metering_point
      t.string  :signing_user
      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney

      t.integer :contracting_party_id

      t.timestamps
    end
  end
end
