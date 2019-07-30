require_relative '../constraints/billing_cycle'
module Schemas
  module Invariants

    BillingCycle = Schemas::Support.Form(Schemas::Constraints::BillingCycle) do

      configure do
        def after?(begin_date, end_date)
          begin_date < end_date
        end

        def not_in_future?(end_date)
          end_date <= Date.today
        end
      end

      rule(last_date: [:begin_date, :end_date]) do |begin_date, end_date|
        end_date.after?(begin_date).and(end_date.not_in_future?)
      end
    end

  end
end
