class AddMigrationscripts < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
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
              if contract.contractor
                contract.customer = contract.contractor
              end
              contract.contractor_id = contracting_party.id
              contracting_party.save
              contract.save
            else
              next
            end
            puts '.'
          end
        end
        puts 'Finished.'


        contracts = Contract.all.where("username IS NOT NULL").where('encrypted_password IS NOT NULL')
        puts 'Going to update ' + contracts.count.to_s + 'Contracts'

        contracts.each do |contract|
          if contract.contractor && contract.contractor.organization && (contract.contractor.organization.slug == "discovergy" || contract.contractor.organization.slug == "buzzn-metering")
            organization = contract.contractor.organization
            register = contract.register
            if register.nil?
              next
            end
            if register.meter.broker.nil?
              broker = DiscovergyBroker.new(
                mode: register.input? ? 'in' : 'out',
                external_id: "EASYMETER_#{register.meter.manufacturer_product_serialnumber}",
                provider_login: contract.username,
                provider_password: contract.password,
                resource: register.meter
              )
              begin
                register.meter.broker = broker
                register.meter.save
              rescue => e
                puts "#{register.meter.manufacturer_product_serialnumber} " + "failed: " + e.inspect
              end
            else
              next
            end
          else
            next
          end
          puts '.'

        end
        puts 'Finished.'
      end
      dir.down do
        raise 'can not down grade'
      end
    end
  end
end
