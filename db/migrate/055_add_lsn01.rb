class AddLsn01 < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'ALTER TYPE templates_name ADD VALUE IF NOT EXISTS \'08_LSN_a01\''
  end

  def down
  end

end
