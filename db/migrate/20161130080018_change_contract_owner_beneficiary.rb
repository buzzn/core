class ChangeContractOwnerBeneficiary < ActiveRecord::Migration
  def change
    add_belongs_to :contracts, :contractor, references: :contracting_parties, index: true, type: :uuid, null: false
    #add_index  :contracts, :contracting_parties, column: :contractor_id
    add_foreign_key :contracts, :contracting_parties, column: :contractor_id

    add_belongs_to :contracts, :customer, references: :contracting_parties, index: true, type: :uuid, null: false
    add_foreign_key :contracts, :contracting_parties, column: :customer_id

    add_belongs_to :contracts, :signing_user, references: :users, index: true, type: :uuid, null: false
    add_foreign_key :contracts, :users, column: :signing_user_id

    reversible do |dir|
      dir.up do
        Contract.all.each do |c|
          c.contractor   = c.contract_owner
          c.customer     = c.contract_beneficiary
          c.signing_user = c.customer.user
        end
      end
      dir.down do
        Contract.all.each do |c|
          c.contract_owner        = c.contractor
          c.contract_beneficiary  = c.customer
          c.origanal_signing_user = c.signing_user.first_name + ' ' + c.signing_user.last_name
        end
      end
    end

    remove_column :contracts, :contract_owner_id, :uuid
    remove_column :contracts, :contract_beneficiary_id, :uuid
    remove_column :contracts, :original_signing_user, :string
  end
end
