require_relative '../constraints/market_location'

module Schemas
  module Invariants

    Billing = Schemas::Support.Form(Schemas::Constraints::Billing) do
      configure do
        def match_group?(localpool, billing_cycle)
          billing_cycle.localpool == localpool
        end
      end

      required(:localpool).filled
      required(:billing_cycle).maybe

      rule(localpool: [:localpool, :billing_cycle]) do |localpool, billing_cycle|
        billing_cycle.filled?.then(billing_cycle.match_group?(localpool))
      end

    end

  end
end
