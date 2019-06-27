class CreateGroupsComments < ActiveRecord::Migration

  def up
    create_table :comments_groups, id: false do |t|
      t.integer :group_id, null: false
      t.integer :comment_id, null: false
      t.index [:group_id, :comment_id], unique: true
    end

    add_foreign_key :comments_groups, :groups, name:   :fk_comments_groups_group
    add_foreign_key :comments_groups, :comments, name: :fk_comments_groups_comment
  end

end
