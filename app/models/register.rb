module FlotConverter
  def self.to_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'].to_i*1000,
        hour['consumption']/1000.0
      ]
    end
    return hours
  end
end


class Register < ActiveRecord::Base
  include FlotConverter


  belongs_to :meter
  belongs_to :metering_point

  scope :in, -> { where(mode: :in) }
  scope :out, -> { where(mode: :out) }





  def day_to_hours
    FlotConverter.to_array Reading.day_to_hours_by_register_id(self.id)
  end



  def self.modes
    %w{
      out
      in
    }
  end

  def self.day_to_hours
    FlotConverter.to_array Reading.day_to_hours_by_slp
  end


  def self.month_to_days
    FlotConverter.to_array Reading.month_to_days_by_slp
  end


  def self.year_to_months
    FlotConverter.to_array Reading.year_to_months_by_slp
  end


end

