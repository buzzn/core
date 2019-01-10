require_relative '../../constraints/group'

module Schemas
  module Invariants
    module Group

      Localpool = Schemas::Support.Form(Constraints::Group) do

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
            case input.class.to_s
            when 'Schemas::Support::ActiveRecordValidator'
              has_owner_role?(input.model)
            when 'Person'
              the_role = input.roles.where(name: Role::GROUP_OWNER).find do |role|
                localpool = role.resource
                owner = localpool.owner
                (owner.is_a?(Person) && input.id == owner.id) ||
                  (owner.is_a?(::Organization::General) && owner.contact && input.id == owner.contact.id)
              end
              the_role != nil
            when 'Organization::General'
              has_owner_role?(input.contact)
            when 'NilClass'
              true
            else
              raise 'can not handle ' + input.class.to_s
            end
          end

          def at_most_one_register_with_same_label?(register)
            register.meter.group.registers.joins(:meta).where('register_meta.label': register.meta.attributes['label']).count <= 1
          end
        end

        required(:distribution_system_operator).maybe { distribution_system_operator? }
        required(:transmission_system_operator).maybe { transmission_system_operator? }
        required(:electricity_supplier).maybe { electricity_supplier? }
        required(:owner).maybe { has_owner_role? }
        required(:grid_feeding_register).maybe { at_most_one_register_with_same_label? }
        required(:grid_consumption_register).maybe { at_most_one_register_with_same_label? }
        required(:gap_contract_tariffs).maybe { unique_begin_date? }
      end

    end
  end
end
