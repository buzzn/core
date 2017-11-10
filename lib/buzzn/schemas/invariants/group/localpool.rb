require_relative '../../constraints/contract/base'
module Schemas
  module Invariants
    module Group
      Localpool = Buzzn::Schemas.Form do

        configure do
          def grid_register_no_group?(input)
            input && input.group.nil?
          end

          def grid_consumption_group?(input)
            input && input.meter.group && input.meter.group.grid_consumption_register == input
          end

          def grid_feeding_group?(input)
            input && input.meter.group && input.meter.group.grid_feeding_register == input
          end
        end

        required(:grid_consumption_register).maybe
        required(:grid_feeding_register).maybe

        required(:grid_consumption_register) do
          grid_consumption_group?.and grid_register_no_group?
        end

        required(:grid_feeding_register) do
          grid_register_no_group?.and grid_feeding_group?
        end
      end
    end
  end
end
