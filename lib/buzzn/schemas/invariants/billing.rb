require_relative '../constraints/billing'
module Schemas
  module Invariants

    Billing = Schemas::Support.Form(Schemas::Constraints::Billing)

  end
end
