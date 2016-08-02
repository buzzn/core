class AddLegalStorageToUser < ActiveRecord::Migration
  def change
    add_column :users, :data_protection_guidelines, :text
    add_column :users, :terms_of_use, :text
  end
end
