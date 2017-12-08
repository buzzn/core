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

          def at_most_one_register_with_same_label?(register)
            register.meter.group.registers.where(label: register.attributes['label']).count <= 1
          end
        end

        required(:distribution_system_operator).maybe { distribution_system_operator? }
        required(:transmission_system_operator).maybe { transmission_system_operator? }
        required(:electricity_supplier).maybe { electricity_supplier? }
        required(:owner).maybe { has_owner_role? }
        required(:grid_feeding_register).maybe { at_most_one_register_with_same_label? }
      end
    end
  end
end
