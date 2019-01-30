module Contract
  class PaymentResource < Buzzn::Resource::Entity

    model Payment

    attributes  :begin_date,
                :price_cents,
                :energy_consumption_kwh_pa,
                :cycle

    attributes :updatable, :deletable

  end
end
