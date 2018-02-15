require_relative 'localpool'

module Schemas
  module Invariants
    module Contract

      LocalpoolRegister = Schemas::Support.Form(Localpool) do

        configure do
          def match_localpool?(localpool, market_location)
            market_location.register.meter.group == localpool
          end
        end

        required(:market_location).filled

        rule(market_location: [:market_location, :localpool]) do |market_location, localpool|
          market_location.match_localpool?(localpool)
        end
      end

    end
  end
end
