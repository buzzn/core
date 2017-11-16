require_relative '../../constraints/contract/base'
module Schemas
  module Invariants
    module Group
      Localpool = Buzzn::Schemas.Form do

        configure do
          def grid_register_no_group?(input)
            input.nil? || input.group.nil?
          end

          def grid_consumption_group?(input)
            input.nil? || input.meter.group && input.meter.group.grid_consumption_register == input
          end

          def grid_feeding_group?(input)
            input.nil? || input.meter.group && input.meter.group.grid_feeding_register == input
          end

          def distribution_system_operator?(input)
            input.nil? || input.in_market_function(:distribution_system_operator) != nil
          end

          def transmission_system_operator?(input)
            input.nil? || input.in_market_function(:transmission_system_operator) != nil
          end

          def electricity_supplier?(input)
            input.nil? || input.in_market_function(:electricity_supplier) != nil
          end
        end

        required(:grid_consumption_register).maybe
        required(:grid_feeding_register).maybe
        required(:distribution_system_operator).maybe { distribution_system_operator? }
        required(:transmission_system_operator).maybe { transmission_system_operator? }
        required(:electricity_supplier).maybe { electricity_supplier? }

        # FIXME needs tests and fix on ITs
        required(:grid_consumption_register) do
          grid_register_no_group?.and grid_consumption_group?
        end

        # FIXME needs tests and fix on ITs
        required(:grid_feeding_register) do
          grid_register_no_group?.and grid_feeding_group?
        end
      end
    end
  end
end
