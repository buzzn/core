require_relative 'base_roda'

module Users
  class Roda < ::BaseRoda

    include Import.args[:env,
                       ]

    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      rodauth.check_session_expiration

      if current_user.nil?
        r.response.status = 401
        r.halt
      end

      admin = AdminResource.new(current_user)

      r.get! do
        Meter::Base.all.select{|m| m.datasource == 'discovergy'}.flat_map(&:registers).

          select{ |r| r.contracts.select { |c| c.is_a? Contract::LocalpoolPowerTaker}.select { |c| c.active? }.any?}.map{ |r|

          contract = r.contracts.select { |c| c.is_a? Contract::LocalpoolPowerTaker}.select { |c| c.active? }.first

          contact_person = nil

          if contract.customer.is_a? Person
            contact_person = contract.customer
          elsif contract.customer.is_a? Organization::General
            contact_person = contract.contractor.contact
          end

          if contact_person.nil?
            raise Exception("contact is nill")
          end

          if contact_person.prefix == 'male'
            gender = 'MALE'
          elsif contact_person.prefix == 'female'
            gender = 'FEMALE'
          else
            gender = 'UNKNOWN'
          end

          {
            id_platform: r.id,
            gender: gender,
            first_name: contact_person.first_name,
            name: contact_person.last_name,
            mail: contact_person.email,
            meter_id: "EASYMETER_#{r.meter.product_serialnumber}",
            role: 'LOCAL_POWER_TAKER',
            #group_community_consumption_meter_id:" => str,
            #group_production_meter_id_first: => str,
            #group_production_meter_id_second: => str
          }
        }
      end
    end
  end
end
