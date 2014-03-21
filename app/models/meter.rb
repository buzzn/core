class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities


  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_meter_id(self.id).each do |hour|
      hours << hour['hourReading']
    end

    return hours.join(', ')
  end


end
