class ChangesRegisterColumns < ActiveRecord::Migration
  def up
    Register::Base.reset_column_information
    Meter::Base.reset_column_information
    rename_column :registers, :direction, :direction_old
    rename_column :registers, :label, :label_old

    create_enum :direction, *Register::Base::DIRECTIONS
    create_enum :label, *Register::Base::LABELS

    add_column :registers, :direction, :direction, index: true
    add_column :registers, :label, :label, index: true
    
    Meter::Base.all.each do |meter|
      meter.update(converter_constant: 1) unless meter.converter_constant
    end

    Register::Base.all.each do |register|
      register.update(direction: register.direction_old,
                      label: register.label_old.upcase)
    end

    remove_column :registers, :direction_old
    remove_column :registers, :label_old
  end

  def down
    raise 'not revertable'
  end
end
