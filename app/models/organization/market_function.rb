module  Organization
  class MarketFunction < ActiveRecord::Base

    belongs_to :organization, class_name: 'Organization::Market'
    belongs_to :contact_person, class_name: 'Person'
    belongs_to :address

    enum function: %i(
      distribution_system_operator
      electricity_supplier
      metering_point_operator
      metering_service_provider
      other
      power_giver
      power_taker
      transmission_system_operator
    ).map.with_object({}) { |key, hash| hash[key] = key.to_s }

  end
end
