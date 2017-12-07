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
              role = input.roles.where(name: Role::GROUP_OWNER).detect do |role|
                localpool = role.resource
                owner = localpool.owner
                (owner.is_a?(Person) && input.id == owner.id) ||
                  (owner.is_a?(::Organization) && owner.contact && input.id == owner.contact.id)
              end
              role != nil
            when Organization
              has_owner_role?(input.contact)
            when NilClass
              true
            else
              raise "can not handle #{input.class}"
            end
          end
        end

        required(:distribution_system_operator).maybe { distribution_system_operator? }
        required(:transmission_system_operator).maybe { transmission_system_operator? }
        required(:electricity_supplier).maybe { electricity_supplier? }
        required(:owner).maybe { has_owner_role? }
      end
    end
  end
end
