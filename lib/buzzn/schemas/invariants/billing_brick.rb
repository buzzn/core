require_relative '../constraints/billing_brick'
module Schemas
  module Invariants

    BillingBrick = Schemas::Support.Form(Schemas::Constraints::BillingBrick) do
      required(:tariff).filled(:int?)
      required(:begin_reading).filled(:int?)
      required(:end_reading).filled(:int?)
    end

  end
end
