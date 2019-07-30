require_relative '../constraints/market_location'

module Schemas
  module Invariants

    MarketLocation = Schemas::Support.Form(Schemas::Constraints::MarketLocation) do
      configure do
        def match_group?(group, register)
          register.meter.group && register.meter.group == group
        end
      end
      required(:group).filled
      required(:register).filled

      rule(group: [:group, :register]) do |group, register|
        register.match_group?(group)
      end

    end

  end
end
