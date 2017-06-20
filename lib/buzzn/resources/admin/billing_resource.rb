module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes  :start_reading_id,
                :end_reading_id,
                :device_change_reading_1_id,
                :device_change_reading_2_id,
                :total_energy_consumption_kWh,
                :total_price_cents,
                :prepayments_cents,
                :receivables_cents,
                :invoice_number,
                :status

    attributes :updatable, :deletable
  end
end
