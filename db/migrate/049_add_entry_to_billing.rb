
class AddEntryToBilling < ActiveRecord::Migration

  def up
    add_belongs_to :billings, :accounting_entry, reference: :accounting_entries, null: true, index: true

    add_foreign_key :billings, :accounting_entries, name: :fk_billings_accounting_entries, column: :accounting_entry_id
  end

  def down
    remove_foreign_key :billings, :accounting_entries
    remove_belongs_to :billings, :accounting_entry
  end

end
