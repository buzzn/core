class AddTariffChangeLetter < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'ALTER TYPE templates_name ADD VALUE IF NOT EXISTS \'13_tariff_change_letter\''
  end

  def down
  end

end
