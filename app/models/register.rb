class Register < ActiveRecord::Base

  belongs_to :meter
  belongs_to :metering_point

  validates :mode, presence: true

  scope :in, -> { where(mode: :in) }
  scope :out, -> { where(mode: :out) }



  def day_to_hours
    if meter.smart
      {
        id:       self.id,
        time_range: 'day_to_hours',
        current:  convert_to_flot_array(Reading.aggregate(:day_to_hours, self.id)),
        past:     convert_to_flot_array(Reading.aggregate(:day_to_hours, self.id))
      }
    else
      {
        id:       self.id,
        time_range: 'day_to_hours',
        current:  convert_to_flot_array(Reading.aggregate(:day_to_hours)),
        past:     convert_to_flot_array(Reading.aggregate(:day_to_hours))
      }
    end
  end



  def month_to_days
    if meter.smart
      {
        id:       self.id,
        time_range: 'month_to_days',
        current:  convert_to_flot_array(Reading.aggregate(:month_to_days, self.id)),
        past:     convert_to_flot_array(Reading.aggregate(:month_to_days, self.id))
      }
    else
      {
        id:       self.id,
        time_range: 'month_to_days',
        current:  convert_to_flot_array(Reading.aggregate(:month_to_days)),
        past:     convert_to_flot_array(Reading.aggregate(:month_to_days))
      }
    end
  end



  def year_to_months
    if meter.smart
      {
        id:       self.id,
        time_range: 'year_to_months',
        current:  convert_to_flot_array(Reading.aggregate(:year_to_months, self.id)),
        past:     convert_to_flot_array(Reading.aggregate(:year_to_months, self.id))
      }
    else
      {
        id:       self.id,
        time_range: 'year_to_months',
        current:  convert_to_flot_array(Reading.aggregate(:year_to_months)),
        past:     convert_to_flot_array(Reading.aggregate(:year_to_months))
      }
    end
  end



private

  def convert_to_flot_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'].to_i*1000,
        hour['consumption']/1000.0
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

