class Meter < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :metering_point

  has_many :registers
  has_many :equipments

  # normalize_attribute :uid, with: [:strip]

  def self.manufacturers
    %w{
      ferraris
      smart_meter
    }
  end

end