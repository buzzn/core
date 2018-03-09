require_relative '../constraints/billing_item'
module Schemas
  module Invariants

    BillingItem = Schemas::Support.Form(Schemas::Constraints::BillingItem) do
      required(:tariff).value(:filled?)
      required(:begin_reading).value(:filled?)
      required(:end_reading).value(:filled?)
    end

  end
end
