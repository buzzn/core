class AddGroupReferenceToTariff < ActiveRecord::Migration
  def change
    change_column :tariffs, :energyprice_cents_per_kwh, :float, null: false
    change_column_null :tariffs, :contract_id, true
    remove_foreign_key :tariffs, column: :contract_id
    add_foreign_key :tariffs, :contracts, name: :fk_tariffs_contract, column_name: :contract_id
    add_reference :tariffs, :group, foreign_key: false, index: true, null: false, type: :uuid
    add_foreign_key :tariffs, :groups, name: :fk_tariffs_group, column_name: :group_id, on_delete: :cascade
  end
end
