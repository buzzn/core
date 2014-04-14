class Organization < ActiveRecord::Base
  has_many :distribution_system_operators
  has_many :electricity_suppliers
  has_many :metering_service_providers
  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, reject_if: :all_blank
end
