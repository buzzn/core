require_relative '../constraints/billing_brick'
module Schemas
  module Invariants

    BillingBrick = Schemas::Support.Form(Schemas::Constraints::BillingBrick) do
      required(:tariff).value(:filled?)
      required(:begin_reading).value(:filled?)
      required(:end_reading).value(:filled?)
    end

  end
end
