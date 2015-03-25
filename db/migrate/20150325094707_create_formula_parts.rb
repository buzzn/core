class CreateFormulaParts < ActiveRecord::Migration
  def change
    create_table :formula_parts do |t|

      t.string  :operator

      t.integer :metering_point_id
      t.integer :operand_id

      t.timestamps null: false
    end
    add_index :formula_parts, :metering_point_id
    add_index :formula_parts, :operand_id
  end
end
