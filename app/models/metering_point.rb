class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include PublicActivity::Model

  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }


  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :uid,
      :slug_name
    ]
  end


  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }


  belongs_to :group

  belongs_to :meter

  has_many :contracts, dependent: :destroy
  has_many :devices
  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  validates :mode, presence: true
  validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
  validates :name, presence: true, length: { in: 2..30 }

  mount_uploader :image, PictureUploader



  default_scope { order('created_at ASC') } #DESC

  scope :inputs, -> { where(mode: :in) }
  scope :outputs, -> { where(mode: :out) }

  scope :without_group, lambda { self.where(group: nil) }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :by_group, lambda {|group|
    self.where(group: group.id)
  }



  def last_two_readings
    latest_readings = Reading.last_two_by_metering_point_id(self.id)
    while latest_readings.any? && latest_readings.first[:timestamp] == latest_readings.last[:timestamp] do
      Reading.where(metering_point_id: self.id).last.delete
      latest_readings = Reading.last_two_by_metering_point_id(self.id)
    end
    if latest_readings.empty?
      return nil
    end
    result = []
    result.push(latest_readings.first[:timestamp].to_i*1000)
    result.push(latest_readings.first[:watt_hour])
    result.push(latest_readings.last[:timestamp].to_i*1000)
    result.push(latest_readings.last[:watt_hour])
    return result
  end



  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def smart?
    if meter
      meter.smart
    else
      false
    end
  end




  def addable_devices
    @users = []
    @users << self.users
    @users << User.with_role(:manager, self)
    (@users).flatten.uniq.collect{|u| u.editable_devices }.flatten
  end

  def metering_point_operator_contract
    if self.contracts.metering_point_operators.running.any?
      return self.contracts.metering_point_operators.running.first
    elsif self.group
      if self.group.contracts.metering_point_operators.running.any?
        return self.group.contracts.metering_point_operators.running.first
      end
    end
  end

  def self.modes
    %w{
      in
      out
    }.map(&:to_sym)
  end







  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      label = node.decorate.name
      if node.mode == "out" && node.devices.any?
        label = label + " | " + node.devices.first.name
      end
      {:label => label, :mode => node.mode, :id => node.id, :children => json_tree(sub_nodes).compact}
    end
  end



  def smart?
    meter && meter.smart?
  end

  def hour_to_minutes(containing_timestamp)
    chart_data(:hour_to_minutes, containing_timestamp)
  end

  def day_to_hours(containing_timestamp)
    chart_data(:day_to_hours, containing_timestamp)
  end

  def week_to_days(containing_timestamp)
    chart_data(:week_to_days, containing_timestamp)
  end

  def month_to_days(containing_timestamp)
    chart_data(:month_to_days, containing_timestamp)
  end

  def year_to_months(containing_timestamp)
    chart_data(:year_to_months, containing_timestamp)
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

  def chart_data(resolution_format, containing_timestamp)
    if self.virtual && self.formula
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      data = []
      operands.each do |metering_point_id|
        data << slp_or_smart(metering_point_id, resolution_format, containing_timestamp)
      end
      return calculate_virtual_metering_point(data, operators)
    else
      slp_or_smart(self.id, resolution_format, containing_timestamp)
    end
  end


  def slp_or_smart(metering_point_id, resolution_format, containing_timestamp)
    metering_point = MeteringPoint.find(metering_point_id)
    if metering_point.meter && metering_point.meter.smart
      convert_to_array(Reading.aggregate(resolution_format, [metering_point.id], containing_timestamp)) # smart
    else
      convert_to_array(Reading.aggregate(resolution_format, nil, containing_timestamp)) # SLP
    end
  end


  def convert_to_array(data)
    hours = []
    data.each do |hour|
      hours << [
        hour['firstTimestamp'].to_i*1000,
        hour['consumption'].to_i/10000000000.0
      ]
    end
    return hours
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

  def calculate_virtual_metering_point(data, operators)
    hours = []
    timestamps = []
    i = 0
    data.each do |metering_point|
      j = 0
      metering_point.each do |reading|
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






  def slug_name
    SecureRandom.uuid
  end


end
















