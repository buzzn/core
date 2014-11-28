class CreateVirtualRegisters < ActiveRecord::Migration
  def change
    create_table :virtual_registers do |t|
      t.integer :register_ids, :array => true
      t.string  :operator
      t.string  :mode
      t.integer :metering_point_id

      t.timestamps
    end
    add_index :virtual_registers, :register_ids
    add_index :virtual_registers, :metering_point_id
  end
end
