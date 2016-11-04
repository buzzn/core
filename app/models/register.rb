class Register < ActiveRecord::Base
  include Filterable
  include Buzzn::GuardedCrud

  belongs_to :metering_point
  belongs_to :meter
  has_many :readings

  validates :obis, presence: true, length: { in: 9..20 }
  validates :label, presence: true, length: { in: 4..30 }


  scope :inputs, -> { where("obis = '1-0:1.8.0'") }
  scope :outputs, -> { where("obis = '1-0:2.8.0'") }
end
