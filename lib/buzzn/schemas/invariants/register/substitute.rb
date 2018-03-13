require_relative 'base'

module Schemas
  module Invariants
    module Register

      Substitute = Schemas::Support.Form(Base) do

        configure do
          def single_substitute?(group)
            group.registers.where(type: 'Register::Substitute').count == 1
          end
        end

        required(:group).maybe

        rule(group: [:group]) do |group|
          group.filled?.then(group.single_substitute?)
        end
      end

    end
  end
end
