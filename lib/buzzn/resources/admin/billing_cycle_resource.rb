require_relative 'billing_resource'

module Admin
  class BillingCycleResource < Buzzn::Resource::Entity

    model BillingCycle

    attributes  :name,
                :begin_date,
                :last_date,
                :status

    has_many :billings, BillingResource

  end
end
