class CreateContractsTariff < ActiveRecord::Migration
  def change
    create_table :contracts_tariffs, id: false do |t|
      t.uuid :tariff_id, null: false
      t.uuid :contract_id, null: false
      t.index [:contract_id, :tariff_id], unique: true
      t.index [:tariff_id, :contract_id], unique: true
    end
    add_foreign_key :contracts_tariffs, :tariffs, name: :fk_contracts_tariffs_tariff
    add_foreign_key :contracts_tariffs, :contracts, name: :fk_contracts_tariffs_contract
  end
end
