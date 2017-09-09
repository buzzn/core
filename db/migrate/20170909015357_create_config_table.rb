class CreateConfigTable < ActiveRecord::Migration
  def change
    create_table :core_configs, id: :uuid do |t|
      t.string :namespace, null: false, size: 64
      t.string :key, null: false, size: 64
      t.string :value, null: false, size: 256      
    end
  end
end
