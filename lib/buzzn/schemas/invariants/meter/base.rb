require_relative '../../constraints/meter/base'

module Schemas
  module Invariants
    module Meter

      Base = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do

        configure do
          def match_group?(group, registers)
            registers.all? { |register| register.group.nil? || register.group == group }
          end
        end

        required(:group).maybe
        required(:registers).filled

        rule(group: [:group, :registers]) do |group, registers|
          group.filled?.then(registers.match_group?(group))
        end
      end

    end
  end
end
