require_relative 'localpool'

module Schemas
  module Invariants
    module Contract
      LocalpoolPowerTaker = Schemas::Support.Form(Localpool) do

        configure do
          def localpool_owner?(localpool, input)
            localpool.nil? || localpool.owner == input
          end
        end

        required(:customer).filled
        required(:contractor).filled

        rule(contractor: [:contractor, :localpool]) do |contractor, localpool|
          contractor.localpool_owner?(localpool)
        end
      end
    end
  end
end
