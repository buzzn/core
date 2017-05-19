module Contract
  class PaymentResource < Buzzn::EntityResource

    model Payment

    attributes  :begin_date,
                :end_date,
                :price_cents,
                :cycle,
                :source
  end
end
