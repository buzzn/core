module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :total_energy_consumption_kwh,
               :total_price_cents,
               :prepayments_cents,
               :receivables_cents,
               :invoice_number,
               :status

    attributes :updatable, :deletable

  end
end
