require_relative '../localpool'

module Schemas::PreConditions::Localpool

  CreateBillingCycle = Schemas::Support.Schema do
    # the resources calculates next_billing_cycle_begin_date using
    # start_date
    required(:start_date).filled
    # TODO this is a broad requirement, it's much more important to have tariffs filled
    # of contracts
    required(:tariffs).value(:min_size? => 1)
    required(:gap_contract_tariffs).value(:min_size? => 1).covers_beginning?(:next_billing_cycle_begin_date)
  end

end
