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
      :slug_name
    ]
  end


  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

  belongs_to :group
  belongs_to :meter

  has_many :formula_parts, dependent: :destroy
  accepts_nested_attributes_for :formula_parts, reject_if: :all_blank, :allow_destroy => true

  has_many :contracts, dependent: :destroy
  has_many :devices
  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy


  validates :readable, presence: true
  validates :mode, presence: true, if: :no_dashboard_metering_point?
  validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
  validates :name, presence: true, length: { in: 2..30 }, if: :no_dashboard_metering_point?

  mount_uploader :image, PictureUploader

  has_many :dashboard_metering_points
  has_many :dashboards, :through => :dashboard_metering_points

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

  def dashboard
    if self.is_dashboard_metering_point
      self.dashboards.collect{|d| d if d.dashboard_metering_points.include?(self)}.first
    end
  end

  def last_power
    if self.virtual && self.formula
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      data = []
      operands.each do |metering_point_id|
        reading = Reading.last_by_metering_point_id(metering_point_id)
        if !reading.nil? && reading[:timestamp] >= Time.now - 1.hour
          data << [[1, reading[:power], reading[:watt_hour]]]
        else
          data << [[1, 0, 0]]
        end
      end
      result = calculate_virtual_metering_point(data, operators)
      if result.any?
        return result[0][1]/1000
      else
        return 0
      end
    else
      last_reading = Reading.last_by_metering_point_id(self.id)
      if last_reading.nil?
        return 0
      end
      return last_reading[:power]/1000
    end
  end



  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_world?
    self.readable == 'world'
  end

  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def smart?
    if meter
      return meter.smart
    else
      if self.virtual
        self.formula_parts.each do |formula_part|
          if !formula_part.operand.smart?
            return false
          end
        end
        return true
      else
        false
      end
    end
  end

  def online?
    if meter
      return meter.online
    else
      if self.virtual
        self.formula_parts.each do |formula_part|
          if !formula_part.operand.online?
            return false
          end
        end
        return true
      else
        false
      end
    end
  end

  def no_dashboard_metering_point?
    !self.is_dashboard_metering_point
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

  def self.readables
    %w{
      me
      friends
      world
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


  def minute_to_seconds(containing_timestamp)
    chart_data(:minute_to_seconds, containing_timestamp)
  end

  def hour_to_minutes(containing_timestamp)
    chart_data(:hour_to_minutes, containing_timestamp)
  end

  def day_to_hours(containing_timestamp)
    chart_data(:day_to_hours, containing_timestamp)
  end

  def day_to_minutes(containing_timestamp)
    chart_data(:day_to_minutes, containing_timestamp)
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

  def formula
    result = ""
    self.formula_parts.each do |formula_part|
      result += formula_part.operator + formula_part.operand_id.to_s
    end
    return result
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
    operands.shift #remove first element of array
    return operands
  end




private

  def get_operators_from_formula
    operators = []
    self.formula.gsub(/\s+/, "").each_char do |char|
      if ['+', '-', '*'].include?(char)
        operators << char
      end
    end
    return operators
  end



  def chart_data(resolution_format, containing_timestamp)
    if self.virtual && self.formula
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      data = []
      operands.each do |metering_point_id|
        if MeteringPoint.find(metering_point_id).smart?
          data << slp_or_smart(metering_point_id, resolution_format, containing_timestamp)
        else
          data << []
        end
      end
      return calculate_virtual_metering_point(data, operators)
    else
      slp_or_smart(self.id, resolution_format, containing_timestamp)
    end
  end


  def slp_or_smart(metering_point_id, resolution_format, containing_timestamp)
    metering_point = MeteringPoint.find(metering_point_id)
    if metering_point.meter && metering_point.meter.smart
      convert_to_array(Reading.aggregate(resolution_format, [metering_point.id], containing_timestamp), resolution_format) # smart
    else
      convert_to_array(Reading.aggregate(resolution_format, nil, containing_timestamp), resolution_format) # SLP
    end
  end


  def convert_to_array(data, resolution_format)
    hours = []
    data.each do |hour|
      if resolution_format == :year_to_months || resolution_format == :month_to_days
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['consumption'].to_i/10000000000.0
        ]
      else
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['avgPower'].to_i/1000
        ]
      end
    end
    return hours
  end




  def calculate_virtual_metering_point(data, operators)
    #hours = []
    timestamps = []
    watts = []
    i = 0
    data.each do |metering_point|
      j = 0
      if metering_point.empty?
        i += 1
        next
      end
      metering_point.each do |reading|
        if i == 0
          timestamps << reading[0]
          watts << reading[1]
          #hours << reading[2]
        else
          if data[i - 1].empty? && timestamps[j].nil?
            timestamps << reading[0]
            watts << reading[1]
          else
            indexOfTimestamp = timestamps.index(reading[0])
            if indexOfTimestamp
              if operators[i] == "+"
                watts[indexOfTimestamp] += reading[1]
                #hours[j] += reading[2]
              elsif operators[i] == "-"
                watts[indexOfTimestamp] -= reading[1]
                #hours[j] -= reading[2]
              elsif operators[i] == "*"
                watts[indexOfTimestamp] *= reading[1]
                #hours[j] *= reading[2]
              end
            end
          end
        end
        j += 1
      end
      i += 1
    end
    result = []
    for i in 0...watts.length
      result << [
        timestamps[i],
        watts[i]
        #hours[i]
      ]
    end
    return result
  end






  def slug_name
    SecureRandom.uuid
  end


end
















