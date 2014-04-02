class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :address, use: [:slugged, :finders]

  validates :address, presence: true, uniqueness: true
  validates :uid,     presence: true, uniqueness: true

  normalize_attribute :address, with: [:strip]
  normalize_attribute :uid,     with: [:strip]


  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_meter_id(self.id).each do |hour|
      hours << hour['hourReading']
    end

    return hours.join(', ')
  end


end
