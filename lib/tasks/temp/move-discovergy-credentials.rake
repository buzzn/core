namespace :migrationscripts do
  desc "Move all discovergy Contract credentials to DiscovergyBroker"
  task :move_discovergy_credentials => :environment do
    contracts = Contract.all.where("username IS NOT NULL").where('encrypted_password IS NOT NULL')
    puts 'Going to update ' + contracts.count.to_s + 'Contracts'
    ActiveRecord::Base.transaction do
      contracts.each do |contract|
        if contract.contractor && contract.contractor.organization && (contract.contractor.organization.slug == "discovergy" || contract.contractor.organization.slug == "buzzn-metering")
          organization = contract.contractor.organization
          register = contract.register
          if register.nil?
            next
          end
          if register.meter.discovergy_broker.nil?
            broker = DiscovergyBroker.create!(
              mode: register.input? ? 'in' : 'out',
              external_id: "EASYMETER_#{register.meter.manufacturer_product_serialnumber}",
              provider_login: contract.username,
              provider_password: contract.password,
              resource: register.meter
            )
            register.meter.discovergy_broker = broker
            register.meter.save!
          else
            next
          end
        else
          next
        end
        puts '.'
      end
    end
    puts 'Finished.'
  end
end