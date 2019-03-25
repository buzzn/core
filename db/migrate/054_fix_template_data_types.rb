class FixTemplateDataTypes < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'ALTER TYPE templates_name ADD VALUE IF NOT EXISTS \'07_LSN_a02\''
  end

  def down
  end

end
