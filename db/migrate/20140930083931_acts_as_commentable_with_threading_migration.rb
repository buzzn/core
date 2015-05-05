class ActsAsCommentableWithThreadingMigration < ActiveRecord::Migration
  def self.up
    enable_extension 'uuid-ossp'
    create_table :comments, :force => true, id: :uuid do |t|
      t.belongs_to :commentable, :default => 0, type: :uuid
      t.string :commentable_type
      t.string :title
      t.text :body
      t.string :subject
      t.belongs_to :user, :default => 0, :null => false, type: :uuid
      t.integer :parent_id, :lft, :rgt
      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    drop_table :comments
  end
end
