class AddPersonToUser < ActiveRecord::Migration
  def change
    add_reference :users, :person, foreign_key: true, index: true, null: true, type: :uuid
  end
end
