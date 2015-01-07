class Register < ActiveRecord::Base

  belongs_to :meter
  belongs_to :metering_point

  validates :mode, presence: true

  scope :in, -> { where(mode: :in) }
  scope :out, -> { where(mode: :out) }




  def hour_to_minutes
    chart_data(:hour_to_minutes)
  end

  def day_to_hours
    chart_data(:day_to_hours)
  end

  def month_to_days
    chart_data(:month_to_days)
  end

  def year_to_months
    chart_data(:year_to_months)
  end

  def get_operands_from_formula
    operands = []
    operand = ""
    self.formula.gsub(/\s+/, "").each_char do |char|
      if ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'].include?(char)
        operand += char
      elsif ['+', '-', '*'].include?(char)
        operands << operand.to_i
        operand = ""
      end
    end
    operands << operand.to_i
    return operands
  end



private

  def chart_data(resolution_format)
    if self.virtual && self.formula
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      data = []
      operands.each do |register_id|
        register = Register.find(register_id)
        data << convert_to_array(Reading.aggregate(resolution_format, register.meter.smart ? [register_id] : nil))
      end
      return calculate_virtual_register(data, operators)
    else
      convert_to_array(Reading.aggregate(resolution_format, meter.smart ? [self.id] : nil))
    end
  end


  def convert_to_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'].to_i*1000,
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


  def get_operators_from_formula
    operators = []
    self.formula.gsub(/\s+/, "").each_char do |char|
      if ['+', '-', '*'].include?(char)
        operators << char
      end
    end
    return operators
  end

  def calculate_virtual_register(data, operators)
    hours = []
    timestamps = []
    i = 0
    data.each do |register|
      j = 0
      register.each do |reading|
        if i == 0
          timestamps << reading[0]
          hours << reading[1]
        else
          timestamps[j] = reading[0]
          if operators[i - 1] == "+"
            hours[j] += reading[1]
          elsif operators[i - 1] == "-"
            hours[j] -= reading[1]
          elsif operators[i - 1] == "*"
            hours[j] *= reading[1]
          end
        end
        j += 1
      end
      i += 1
    end
    result = []
    for i in 0...hours.length
      result << [
        timestamps[i],
        hours[i]
      ]
    end
    return result
  end

end

