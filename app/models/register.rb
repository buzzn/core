class Register < ActiveRecord::Base
  include Filterable
  include Buzzn::GuardedCrud

  belongs_to :metering_point
  belongs_to :meter
  has_many :readings

  # obis is a string that contains information about the measured values,
  #   e.g. it contains information about the direction of the power (in vs. out)
  #   for more information see http://www.edi-energy.de/files2/EDI@Energy-Codeliste-OBIS-Kennzahlen_2_2e_20160401.pdf
  validates :obis, presence: true, length: { in: 9..20 }
  validates :label, presence: true, length: { in: 4..30 }


  scope :inputs, -> { where("obis = '1-0:1.8.0'") }
  scope :outputs, -> { where("obis = '1-0:2.8.0'") }
end
