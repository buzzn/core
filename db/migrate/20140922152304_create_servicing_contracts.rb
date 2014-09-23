class CreateServicingContracts < ActiveRecord::Migration
  def change
    create_table :servicing_contracts do |t|
      t.string  :tariff
      t.string  :status
      t.string  :signing_user
      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney
      t.date    :commissioning
      t.date    :termination

      t.integer :organization_id
      t.integer :contracting_party_id
      t.integer :group_id

      t.timestamps
    end
  end
end
