class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :location
  acts_as_list scope: :location

  belongs_to :contract

  has_one :meter
  accepts_nested_attributes_for :meter, reject_if: :all_blank

  has_many :distribution_system_operators
  has_many :electricity_suppliers
  has_many :metering_service_providers

  has_and_belongs_to_many :devices
end
