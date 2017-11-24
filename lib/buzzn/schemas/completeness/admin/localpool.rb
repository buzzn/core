require_relative '../../../resources/organization_resource'
require_relative '../organization'
module Schemas
  module Completeness
    module Admin
      Localpool = Buzzn::Schemas.Schema do

        configure do
          def metering_point_id?(input)
            ! input.metering_point_id.nil?
          end
        end

        required(:owner) do
          ((filled?.and type?(OrganizationResource)).then schema(Schemas::Completeness::Organization)).and(filled?)
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
      end
    end
  end
end
