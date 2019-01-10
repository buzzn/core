class CreateGroupGapContractTariff < ActiveRecord::Migration

  def change
    create_table :groups_gap_contract_tariffs, id: false do |t|
      t.integer :tariff_id, null: false
      t.integer :group_id, null: false
      t.index [:group_id, :tariff_id], unique: true
      t.index [:tariff_id, :group_id], unique: true
    end

    add_foreign_key :groups_gap_contract_tariffs, :tariffs, name: :fk_groups_gap_contract_tariffs_tariff
    add_foreign_key :groups_gap_contract_tariffs, :groups, name: :fk_groups_gap_contract_tariffs_group
  end

end
