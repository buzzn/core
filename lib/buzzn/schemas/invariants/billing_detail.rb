require_relative '../constraints/billing_detail'
module Schemas
  module Invariants

    BillingDetail = Schemas::Support.Form(Schemas::Constraints::BillingDetail) do

    end

  end
end
