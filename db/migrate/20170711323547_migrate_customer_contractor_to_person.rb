class MigrateCustomerContractorToPerson < ActiveRecord::Migration
  def up
    Contract::Base.all.each do |contract|
      if contract.customer_type == 'User'
        contract.update(customer: contract.customer.person)
      end
      if contract.contractor_type == 'User'
        contract.update(contractor: contract.contractor.person)
      end
    end
    BankAccount.all.each do |account|
      if account.contracting_party_type == 'User'
        account.update(contracting_party: account.contracting_party.person)
      end
    end
  end
end
