class ChangeCommentParentIdToUuid < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
    remove_column :comments, :parent_id
    add_column :comments, :parent_id, :uuid
  end

  def down
    remove_column :comments, :parent_id
    add_column :comments, :parent_id
  end
end
