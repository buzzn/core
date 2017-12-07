module Schemas
  module Invariants
    module Group
      Localpool = Schemas::Support.Form do

        configure do
          def distribution_system_operator?(input)
            input.nil? || input.in_market_function(:distribution_system_operator) != nil
          end

          def transmission_system_operator?(input)
            input.nil? || input.in_market_function(:transmission_system_operator) != nil
          end

          def electricity_supplier?(input)
            input.nil? || input.in_market_function(:electricity_supplier) != nil
          end

          def has_owner_role?(input)
            case input
            when Person
              the_role = input.roles.where(name: Role::GROUP_OWNER).detect do |role|
                localpool = role.resource
                owner = localpool.owner
                (owner.is_a?(Person) && input.id == owner.id) ||
                  (owner.is_a?(::Organization) && owner.contact && input.id == owner.contact.id)
              end
              the_role != nil
            when Organization
              has_owner_role?(input.contact)
            when NilClass
              true
            else
              raise "can not handle #{input.class}"
            end
          end

          def at_most_one_grid_feeding_register?(input)
            registers = ::Group::Base.find(input).registers
            registers.grid_feeding.size <= 1
          end

          # def at_most_one_grid_consumption_register?(input)
          #   registers = ::Group::Base.find(input).registers
          #   registers.grid_consumption.size <= 1
          # end
        end

        required(:distribution_system_operator).maybe { distribution_system_operator? }
        required(:transmission_system_operator).maybe { transmission_system_operator? }
        required(:electricity_supplier).maybe { electricity_supplier? }
        required(:owner).maybe { has_owner_role? }
        # I don't know how to define a rule on the whole object where I can execute regular active record code, and still pass in the :id
        required(:id).maybe { at_most_one_grid_feeding_register? }
        # required(:id).maybe { at_most_one_grid_consumption_register? }
        # rule(at_most_one_grid_feeding_register: [:id]) do |id|
        #   at_most_one_grid_feeding_register?(id)
        # end
        # required(:registers).maybe { at_most_one_grid_feeding_register? }
      end
    end
  end
end
