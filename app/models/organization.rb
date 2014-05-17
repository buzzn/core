class Organization < ActiveRecord::Base
  has_many :distribution_system_operator_contracts
  has_many :electricity_supplier_contracts
  has_many :metering_service_provider_contracts
  has_many :contracting_parties

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank


  scope :electricity_suppliers, -> { where(mode: 'electricity_supplier') }
  scope :metering_service_providers, -> { where(mode: 'metering_service_provider') }

end
