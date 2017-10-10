module Contract
  class PaymentResource < Buzzn::Resource::Entity

    model Payment

    attributes  :begin_date,
                :end_date,
                :price_cents,
                :cycle

    def updated_at; nil; end
  end
end
