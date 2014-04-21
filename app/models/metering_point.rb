class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :location
  acts_as_list scope: :location

  belongs_to :contract

  has_one :meter
  accepts_nested_attributes_for :meter, reject_if: :all_blank

  has_many :distribution_system_operator_contracts
  has_many :electricity_supplier_contracts
  has_many :metering_service_provider_contracts

  has_many :devices

  
  validates :location_id, presence: true
  validates :mode, presence: true

end
