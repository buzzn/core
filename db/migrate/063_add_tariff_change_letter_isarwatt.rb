class AddTariffChangeLetterIsarwatt < ActiveRecord::Migration
  def up
    execute 'ALTER TYPE templates_name ADD VALUE IF NOT EXISTS \'14_tariff_change_letter_isarwatt\''
  end

  def down
  end

end
