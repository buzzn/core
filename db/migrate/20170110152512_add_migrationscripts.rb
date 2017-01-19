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
              contracting_party.save!
              contract.save!
              puts "#{contract.id} - successfully changed."
            else
              puts "#{contract.id} - failed: no organization."
              next
            end
          end
        end
        puts 'Finished.'

        contracts = Contract.all.where("username IS NOT NULL").where('encrypted_password IS NOT NULL')
        puts 'Going to update ' + contracts.count.to_s + 'Contracts'

        contracts.each do |contract|
          if contract.contractor && contract.contractor.organization_id
            organization = Organization.find(contract.contractor.organization_id)
          elsif contract.organization_id
            organization = Organization.find(contract.organization_id)
          else
            puts "#{contract.id} - failed: no contractor or no organization."
            next
          end
          if !(organization.slug == "discovergy" || organization.slug == "buzzn-metering")
            puts "#{contract.id} - failed: no discovergy contract."
            next
          end

          if !contract.register_id
            puts "#{contract.id} - failed: no register_id."
            next
          end
          begin
            register = Register::Base.find(contract.register_id)
          rescue => e
            puts "#{contract.id} - failed: no register found."
            contract.delete
            puts "#{contract.id} - deleted."
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
              register.meter.save!
              puts "#{contract.id}: successfully transferred."
            rescue => e
              puts "#{register.meter.manufacturer_product_serialnumber} " + "failed: " + e.inspect
            end
          else
            puts "#{contract.id} - already has a broker."
            next
          end
        end
        puts 'Finished.'
      end
      dir.down do
        raise 'can not down grade'
      end
    end
  end
end
