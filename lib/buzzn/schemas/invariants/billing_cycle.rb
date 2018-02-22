require_relative '../constraints/billing_cycle'
module Schemas
  module Invariants

    BillingCycle = Schemas::Support.Form(Schemas::Constraints::BillingCycle) do

      configure do
        def after?(begin_date, end_date)
          begin_date < end_date
        end
      end

      rule(end_date: [:begin_date, :end_date]) do |begin_date, end_date|
        end_date.after?(begin_date)
      end
    end

  end
end
