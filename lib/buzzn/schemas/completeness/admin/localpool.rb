require_relative '../../../resources/organization_resource'
require_relative '../../../resources/person_resource'
require_relative '../admin'
require_relative '../organization'
require_relative '../person'
module Schemas::Completeness::Admin
  Localpool = Schemas::Support.Schema do

    configure do
      def metering_point_id?(input)
        ! input.metering_point_id.nil?
      end
    end

    required(:owner) do
      filled?.and(
        type?(OrganizationResource).then schema(Schemas::Completeness::Organization)).and(
        type?(PersonResource).then schema(Schemas::Completeness::Person))
    end

    required(:grid_feeding_register) do
      filled?.then(metering_point_id?).and filled?
    end

    required(:grid_consumption_register) do
      filled?.then(metering_point_id?).and filled?
    end

    required(:distribution_system_operator).filled
    required(:transmission_system_operator).filled
    required(:electricity_supplier).filled
    required(:bank_account).filled
    required(:address).filled
  end
end
