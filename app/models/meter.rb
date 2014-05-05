class Meter < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :metering_point

  # normalize_attribute :uid, with: [:strip]

  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_meter_id(self.id).each do |hour|
      hours << hour['hourReading']
    end

    return hours.join(', ')
  end

  def self.manufacturers
    %w{ ferraris smart_meter }
  end

end
