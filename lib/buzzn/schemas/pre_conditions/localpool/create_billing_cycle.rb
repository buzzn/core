require_relative '../localpool'

module Schemas::PreConditions::Localpool

  CreateBillingCycle = Schemas::Support.Schema do
    # the resources calculates next_billing_cycle_begin_date using
    # start_date
    required(:start_date).filled
    # TODO check that tariffs covers beginning of cycle
    required(:tariffs).value(:min_size? => 1)
  end

end
