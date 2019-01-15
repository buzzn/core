require_relative 'billing_item_resource'

module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :begin_date,
               :end_date,
               :last_date,
               :invoice_number,
               :status

    has_one :contract
    has_many :items, BillingItemResource

    def invoice_number
      object.full_invoice_number
    end

  end
end
