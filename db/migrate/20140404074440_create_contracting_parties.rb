class CreateContractingParties < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :contracting_parties, id: :uuid do |t|
      t.string :slug
      t.string :legal_entity

      t.integer :sales_tax_number
      t.float   :tax_rate
      t.integer :tax_number

      t.belongs_to :organization, type: :uuid
      t.belongs_to :metering_point, type: :uuid
      t.belongs_to :user, type: :uuid

      t.timestamps
    end
    add_index :contracting_parties, :slug, :unique => true
    add_index :contracting_parties, :metering_point_id
    add_index :contracting_parties, :user_id
    add_index :contracting_parties, :organization_id
  end
end
