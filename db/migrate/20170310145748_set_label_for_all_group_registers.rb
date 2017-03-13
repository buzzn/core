class SetLabelForAllGroupRegisters < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        puts 'Updating Register::Base.label attribute'
        ActiveRecord::Base.transaction do
          Group::Localpool.all.each do |group|
            group.input_registers.update_all(label: 'consumption')
            group.output_registers.each do |register|
              register.update_column(:label, register.name.include?('BHKW') ? 'production_chp' : 'production_pv')
            end
          end
          consumption_names = ['Netzbezug', 'ÜGZ Bezug']
          feeding_names = ['Einspeisung', 'ÜGZ Einspeisung', 'Netzeinspeis']
          Register::Base.all.where(label: nil).each do |register|
            register_name = register.name
            consumption_names.each do |name|
              if register_name.include?(name)
                register.update_column(:label, 'grid_consumption')
                break
              end
            end
            feeding_names.each do |name|
              if register_name.include?(name)
                register.update_column(:label, 'grid_feeding')
                break
              end
            end
            if register_name.include?('Abgrenzung')
              if register_name.include?('PV')
                register.update_column(:label, 'demarcation_pv')
              elsif register_name.include?('BHKW')
                register.update_column(:label, 'demarcation_chp')
              end
              next
            end
          end
        end
      end

      dir.down do
        raise 'can not down grade'
      end
    end
  end
end
