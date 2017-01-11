class AddForeignKeyToRegisters < ActiveRecord::Migration
  def change
    add_foreign_key :registers, :meters, null: false
    reversible do |dir|
      dir.up do
        Meter::Real.all.each do |m|
          m.delete if m.registers.empty?
        end
        Meter::Virtual.all.each do |m|
          m.delete unless m.register
        end
        puts 'invalid meters'
        Meter::Base.all.each do |m|
          unless m.valid?
            puts "Meter::Base : #{m.id} : #{m.errors.messages.inspect}"
          end
        end
      end
      dir.down do
        raise 'can not down grade'
      end
    end
  end
end
