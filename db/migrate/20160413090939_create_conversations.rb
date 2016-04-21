class CreateConversations < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :conversations, id: :uuid do |t|

      t.timestamps null: false
    end
  end
end
