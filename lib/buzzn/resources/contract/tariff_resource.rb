module Contract
  class TariffResource < Buzzn::Resource::Entity

    model Tariff

    attributes  :name,
                :begin_date,
                :end_date,
                :energyprice_cents_per_kwh,
                :baseprice_cents_per_month
  end
end
