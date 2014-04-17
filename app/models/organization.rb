class Organization < ActiveRecord::Base
  has_many :distribution_system_operator_contracts
  has_many :electricity_supplier_contracts
  has_many :metering_service_provider_contracts
  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, reject_if: :all_blank
end
