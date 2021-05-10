class AddYearToEnergyClassifications < ActiveRecord::Migration

  def up
    add_column :energy_classifications, :year, :int
  end

  def down
    remove_column :energy_classifications, :year
  end

end
