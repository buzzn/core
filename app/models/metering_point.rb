class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :location
  acts_as_list scope: :location

  belongs_to :contract

  belongs_to :group

  has_one :meter
  has_one :distribution_system_operator_contract
  has_one :electricity_supplier_contract
  has_one :metering_service_provider_contract
  has_many :devices

  has_many :metering_point_users
  has_many :users, :through => :metering_point_users

  #validates :uid, uniqueness: true
  validates :mode, presence: true


  def self.modes
    %w{
      up_metering
      down_metering
      up_down_metering
    }
  end

  def self.voltages
    %w{
      low
      medium
      high
      highest
    }
  end

  def self.regular_intervals
    %w{
      monthly
      annually
      quarterly
      half_yearly
    }
  end



  def name
    "#{location.address.name}_#{address_addition}"
  end

  def up_metering?
    self.mode == 'up_metering'
  end

  def down_metering?
    self.mode == 'down_metering'
  end

  def up_down_metering?
    self.mode == 'up_down_metering'
  end

end
