class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :uid, use: [:slugged, :finders]

  validates :uid,     presence: true, uniqueness: true

  normalize_attribute :uid, with: [:strip]


  has_one :meter_electricity_supplier
  has_one :power_generator
  has_one :address, as: :addressable

  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_meter_id(self.id).each do |hour|
      hours << hour['hourReading']
    end

    return hours.join(', ')
  end


end
