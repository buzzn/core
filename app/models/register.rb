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

  def self.standart_profile_day_to_hours
    [[0, 3], [1, 3], [2, 5], [3, 7], [4, 8], [5, 10], [6, 11], [7, 9], [8, 5], [9, 13]]
  end

  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_register_id(self.id).each_with_index do |hour, index|
      hours << [index, hour['hourReading']]
    end
    return hours
  end


end
