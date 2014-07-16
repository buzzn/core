class Register < ActiveRecord::Base

  belongs_to :meter
  belongs_to :metering_point


  def self.convert_to_flot_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'].to_i*1000,
        hour['consumption']
      ]
    end
    return hours
  end




  def day_to_hours
    convert_to_flot_array Reading.day_to_hours_by_register_id(self.id)
  end







  def self.modes
    %w{
      out
      in
    }
  end

  def self.day_to_hours
    convert_to_flot_array Reading.day_to_hours_by_slp
  end


  def self.month_to_days
    convert_to_flot_array Reading.month_to_days_by_slp
  end


  def self.year_to_months
    convert_to_flot_array Reading.year_to_months_by_slp
  end




end
