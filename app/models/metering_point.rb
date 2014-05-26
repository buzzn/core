class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :location
  acts_as_list scope: :location

  belongs_to :contract

  has_one :meter
  has_one :distribution_system_operator_contract
  has_one :electricity_supplier_contract
  has_one :metering_service_provider_contract
  has_many :devices

  validates :uid, presence: true, uniqueness: true
  validates :mode, presence: true

  def name
    "#{location.address.name}_#{address_addition}"
  end

  def up_metering?
    self.mode == 'up_metering'
  end

end
