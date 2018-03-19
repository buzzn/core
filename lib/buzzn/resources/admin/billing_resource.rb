require_relative 'billing_item_resource'

module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :begin_date,
               :end_date,
               :status

    has_one :contract
    has_many :items, BillingItemResource

    def begin_date
      object.date_range.first
    end

    def end_date
      object.date_range.last
    end

  end
end
