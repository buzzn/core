namespace :migrationscripts do
  desc "Update all contracts and organizations to connect with a contracting_party class"
  task update_contract_organization: :environment do
    contracts = Contract.all
    puts 'Going to update ' + contracts.count.to_s + 'Contracts'
    ActiveRecord::Base.transaction do
      contracts.each do |contract|
        if contract.organization_id
          organization = Organization.find(contract.organization_id)
          if organization.contracting_party.nil?
            contracting_party = ContractingParty.create(legal_entity: 'company', organization: organization)
          else
            contracting_party = organization.contracting_party
          end
          if contract.contract_owner_id
            contract.contract_beneficiary_id = contract.contract_owner_id
          end
          contract.contract_owner_id = contracting_party.id
          contracting_party.save
          contract.save
        else
          next
        end
        puts '.'
      end
    end
    puts 'Finished.'
  end
end