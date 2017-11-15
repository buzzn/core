class CreatePersonsRoles < ActiveRecord::Migration
  def change
    create_table :persons_roles, id: false do |t|
      t.uuid :person_id, null: false
      t.integer :role_id, null: false
      t.index [:person_id, :role_id]
      t.index [:role_id, :person_id]
    end
  end
end
