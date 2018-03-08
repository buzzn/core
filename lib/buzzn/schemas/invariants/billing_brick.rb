require_relative '../constraints/billing_brick'
module Schemas
  module Invariants

    BillingBrick = Schemas::Support.Form(Schemas::Constraints::BillingBrick) do
      required(:tariff_id).filled(:int?)
      required(:begin_reading_id).filled(:int?)
      required(:end_reading_id).filled(:int?)
    end

  end
end
