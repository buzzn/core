module Contract
  class TariffResource < Buzzn::Resource::Entity

    model Tariff

    attributes  :name,
                :begin_date,
                :end_date,
                :energyprice_cents_per_kwh,
                :baseprice_cents_per_month,
                :number_of_contracts

    attributes :updatable, :deletable

    def deletable
      super && object.contracts.empty?
    end

    def number_of_contracts
      object.contracts.count
    end
  end
end
