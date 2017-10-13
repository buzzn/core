class OrganizationMarketFunction < ActiveRecord::Base

  belongs_to :organization

  enum role_name: %i(
    distribution_system_operator
    electricity_supplier
    metering_point_operator
    metering_service_provider
    other
    power_giver
    power_taker
    transmission_system_operator
  )

  # TODO add enum/constraints
  validates :function_name, uniqueness: { scope: :organization }, inclusion: self.role_names.keys
  validates :market_partner_id, uniqueness: true

  get_from_org_if_empty = %i(name contact_person address)
  get_from_org_if_empty.each do |attr|
    define_method(attr) do
      read_attribute(attr) || organization.send(attr)
    end
  end

  delegate :legal_representative_person, to: :organization
end
