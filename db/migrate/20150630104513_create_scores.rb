class CreateScores < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :scores, id: :uuid do |t|
      t.string :mode
      t.string :interval
      t.timestamp :interval_beginning
      t.timestamp :interval_end
      t.float :value
      t.references :scoreable, :polymorphic => true, type: :uuid

      t.timestamps
    end

    add_index :scores, :scoreable_id
    add_index :scores, [:scoreable_id, :scoreable_type]
  end
end
