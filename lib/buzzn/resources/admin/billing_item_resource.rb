module Admin
  class BillingItemResource < Buzzn::Resource::Entity

    model BillingItem

    attributes  :begin_date,
                :last_date,
                :begin_reading_kwh,
                :end_reading_kwh,
                :consumed_energy_kwh,
                :length_in_days,
                :base_price_cents,
                :energy_price_cents,
                :incompleteness

    has_one :tariff
    has_one :meter

    def begin_reading_kwh
      begin_reading.value / 1000 if begin_reading
    end

    def end_reading_kwh
      end_reading.value / 1000 if end_reading
    end

  end
end
