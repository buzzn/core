class ChangeContractContractingParty < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
    remove_column :contracts, :contracting_party_id, :uuid
    add_column :contracts, :contract_owner_id, :uuid
    add_column :contracts, :contract_beneficiary_id, :uuid
  end

  def down
    enable_extension 'uuid-ossp'
    add_column :contracts, :contracting_party_id, :uuid
    remove_column :contracts, :contract_owner_id, :uuid
    remove_column :contracts, :contract_beneficiary_id, :uuid
  end
end
