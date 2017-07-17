class AddPersonToOrganization < ActiveRecord::Migration
  def change
    add_reference :organizations, :contact, index: true, null: true, type: :uuid
    add_foreign_key :organizations, :persons, column: :contact_id
  end
end
