class OrganizationMarketFunction < ActiveRecord::Base

  # TODO add FK constraints
  belongs_to :organization
  belongs_to :contact_person, class_name: "Person"
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

  validates :organization_id, presence: true
  validates :edifact_email, presence: true
  validates :function, presence: true, uniqueness: { scope: :organization_id }
  validates :market_partner_id, presence: true, uniqueness: true
end
