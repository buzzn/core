class SetLabelsForRemainingRegisters < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        puts 'Updating Register::Base.label attribute'
        Register::Base.where(label: nil).each do |register|
          if register.direction == :in
            register.label = Register::Base::CONSUMPTION
            if register.name.include?('Übergabe') || register.name.include?('ÜGZ')
              register.label = Register::Base::GRID_CONSUMPTION
            end
          else
            register.label = Register::Base::PRODUCTION_PV
            if register.name.include?('Übergabe') || register.name.include?('ÜGZ')
              register.label = Register::Base::GRID_FEEDING
            elsif register.name.include?('BHKW')
              register.label = Register::Base::PRODUCTION_CHP
            end
          end
          register.save!
        end
      end
    end
  end
end
