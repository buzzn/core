module Contract
  class PaymentResource < Buzzn::Resource::Entity

    model Payment

    attributes  :begin_date,
                :price_cents,
                :energy_consumption_kwh_pa,
                :cycle

    attributes :updatable, :deletable

    # tariff used for calculation of that payment
    has_one :tariff, Contract::TariffResource

  end
end
