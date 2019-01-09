module Contract
  class ContextedTariffResource < Buzzn::Resource::Entity

    model Contract::ContextedTariff

    attributes :begin_date,
               :end_date,
               :last_date

    has_one :tariff

  end
end
