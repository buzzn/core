module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :invoice_number,
               :status

    attributes :updatable, :deletable

  end
end
