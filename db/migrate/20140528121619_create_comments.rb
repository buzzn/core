class CreateComments < ActiveRecord::Migration
  def self.up
    enable_extension 'uuid-ossp'
    create_table :comments, id: :uuid do |t|
      t.string :title, :limit => 50, :default => ""
      t.text :comment
      t.references :commentable, :polymorphic => true, type: :uuid
      t.references :user, type: :uuid
      t.string :role, :default => "comments"
      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
