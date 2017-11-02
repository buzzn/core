class CreateFormulaPartsOld < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :formula_parts, id: :uuid do |t|
      t.string  :operator

      t.belongs_to :metering_point, type: :uuid
      t.belongs_to :operand, type: :uuid

      t.timestamps null: false
    end
    add_index :formula_parts, :metering_point_id
    add_index :formula_parts, :operand_id
  end
end
