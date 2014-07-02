class Register < ActiveRecord::Base

  belongs_to :meter
  belongs_to :metering_point

  def self.modes
    %w{
      up
      down
      up_down
    }
  end

  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_register_id(self.id).each_with_index do |hour, index|
      hours << [index, hour['hourReading']]
    end
    return hours
  end


end
