class AddPersonToUser < ActiveRecord::Migration
  def change
    #add_reference :users, :person, foreign_key: :true, index: true, null: true, type: :uuid
    # the above does not work as
    add_column :users, :person_id, :uuid
    add_foreign_key :users, :persons, index: true, null: true
  end
end
