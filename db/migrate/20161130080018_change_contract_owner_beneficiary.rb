class ChangeContractOwnerBeneficiary < ActiveRecord::Migration
  def change
    add_belongs_to :contracts, :contractor, references: :contracting_parties, index: true, type: :uuid
    add_foreign_key :contracts, :contracting_parties, column: :contractor_id, null: false

    add_belongs_to :contracts, :customer, references: :contracting_parties, index: true, type: :uuid
    add_foreign_key :contracts, :contracting_parties, column: :customer_id, null: false

    add_belongs_to :contracts, :signing_user, references: :users, index: true, type: :uuid
    add_foreign_key :contracts, :users, column: :signing_user_id, null: false

    reversible do |dir|
      dir.up do
        Contract.all.each do |c|
          if c.contract_owner_id
            c.contractor   = ContractingParty.find(c.contract_owner_id)
            puts 'contract: ' + c.id + ' .... contractor: ' + c.contractor_id
          else
            puts "#{c.id}: no contract_beneficiary_id."
          end
          if c.contract_beneficiary_id
            c.customer     = ContractingParty.find(c.contract_beneficiary_id)
            c.signing_user = c.customer.user
            puts 'contract: ' + c.id + ' .... customer: ' + c.customer_id
          else
            puts "#{c.id}: no contract_beneficiary_id."
          end
        end
      end
      dir.down do
        Contract.all.each do |c|
          if c.contractor_id
            c.contract_owner       = ContractingParty.find(c.contractor_id)
          end
          if c.customer_id
            c.contract_beneficiary = ContractingParty.find(c.customer_id)
          end
          c.origanal_signing_user  = c.signing_user.first_name + ' ' + c.signing_user.last_name
        end
      end
    end

    remove_column :contracts, :contract_owner_id, :uuid
    remove_column :contracts, :contract_beneficiary_id, :uuid
    remove_column :contracts, :original_signing_user, :string
  end
end
