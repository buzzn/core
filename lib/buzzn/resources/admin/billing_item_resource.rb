module Admin
  class BillingItemResource < Buzzn::Resource::Entity

    model BillingItem

    attributes  :begin_date,
                :end_date,
                :begin_reading_kwh,
                :end_reading_kwh,
                :consumed_energy_kwh,
                :length_in_days,
                :base_price_cents,
                :energy_price_cents

    has_one :tariff
    has_one :meter

    def begin_reading_kwh
      begin_reading.value / 1000
    end

    def end_reading_kwh
      end_reading.value / 1000
    end

    def begin_date
      object.date_range.first
    end

    def end_date
      object.date_range.last
    end

  end
end
