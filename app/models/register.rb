class Register < ActiveRecord::Base

  belongs_to :meter
  belongs_to :metering_point

  validates :mode, presence: true

  scope :in, -> { where(mode: :in) }
  scope :out, -> { where(mode: :out) }

  def hour_to_minutes
    if meter.smart
      convert_to_array(Reading.aggregate(:hour_to_minutes, [self.id]))
    else
      convert_to_array(Reading.aggregate(:hour_to_minutes))
    end
  end


  def day_to_hours
    if meter.smart
      convert_to_array(Reading.aggregate(:day_to_hours, [self.id]))
    else
      convert_to_array(Reading.aggregate(:day_to_hours))
    end
  end



  def month_to_days
    if meter.smart
      convert_to_array(Reading.aggregate(:month_to_days, [self.id]))
    else
      convert_to_array(Reading.aggregate(:month_to_days))
    end
  end



  def year_to_months
    if meter.smart
      convert_to_array(Reading.aggregate(:year_to_months, [self.id]))
    else
      convert_to_array(Reading.aggregate(:year_to_months))
    end
  end



private

  def convert_to_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'],
        hour['consumption'].to_i/1000.0
      ]
    end
    return hours
  end


  def self.modes
    %w{
      out
      in
    }
  end



end

