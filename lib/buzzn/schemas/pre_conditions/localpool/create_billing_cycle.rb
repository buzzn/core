require_relative '../localpool'

module Schemas::PreConditions::Localpool

  CreateBillingCycle = Schemas::Support.Schema do
    # the resources calculates next_billing_cycle_begin_date using
    # start_date
    required(:start_date).filled
  end

end
