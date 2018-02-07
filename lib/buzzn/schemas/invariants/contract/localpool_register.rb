require_relative 'localpool'

module Schemas
  module Invariants
    module Contract
      LocalpoolRegister = Schemas::Support.Form(Localpool) do

        configure do
          def match_localpool?(localpool, register)
            register.meter.group == localpool
          end
        end

        required(:register).filled

        rule(register: [:register, :localpool]) do |register, localpool|
          register.match_localpool?(localpool)
        end
      end
    end
  end
end
