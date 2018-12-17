require_relative 'billing_item_resource'

module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :begin_date,
               :last_date,
               :invoice_number,
               :status

    has_one :contract
    has_many :items, BillingItemResource

  end
end
