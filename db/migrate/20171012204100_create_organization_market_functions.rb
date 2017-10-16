class CreateOrganizationMarketFunctions < ActiveRecord::Migration
  def change
    create_table :organization_market_functions, id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
      # TODO: add foreign key
      t.references :organization
      # TODO: add enum
      t.string :function
      t.string :market_partner_id
      t.string :edifact_email
      # TODO: add foreign keys
      t.integer :contact_person_id
      t.integer :address_id

      # TODO
      # add_reference :organization, :contact, index: true, null: true, type: :uuid
      # add_foreign_key :organization, :persons, column: :contact_id
    end
  end
end
