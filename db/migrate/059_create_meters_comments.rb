class CreateMetersComments < ActiveRecord::Migration

  def up
    create_table :comments_meters, id: false do |t|
      t.integer :meter_id, null: false
      t.integer :comment_id, null: false
      t.index [:meter_id, :comment_id], unique: true
    end

    add_foreign_key :comments_meters, :meters, name:   :fk_comments_meters_meter
    add_foreign_key :comments_meters, :comments, name: :fk_comments_meters_comment
  end

end
