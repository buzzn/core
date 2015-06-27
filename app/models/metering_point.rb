class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include CalcVirtualMeteringPoint

  include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  #tracked recipient: Proc.new{ |controller, model| controller && model }

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
  validates :meter, presence: false, if: :virtual

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

  scope :editable_by_user_without_meter_not_virtual, lambda {|user|
    self.with_role(:manager, user).where(meter: nil).where(virtual: false)
  }

  scope :by_group, lambda {|group|
    self.where(group: group.id)
  }

  def managers
    User.with_role :manager, self
  end

  def dashboard
    if self.is_dashboard_metering_point
      self.dashboards.collect{|d| d if d.dashboard_metering_points.include?(self)}.first
    end
  end

  def last_power
    if self.virtual && self.formula_parts.any?
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      result = 0
      i = 0
      count_timestamps = 0
      sum_timestamp = 0
      operands.each do |metering_point_id|
        reading = Reading.last_by_metering_point_id(metering_point_id)
        if !reading.nil? #&& reading[:timestamp] >= Time.now - 1.hour
          if operators[i] == "+"
            result += reading[:power]
          elsif operators[i] == "-"
            result -= reading[:power]
          end
          sum_timestamp += reading[:timestamp].to_i*1000
          count_timestamps += 1
        end
        i+=1
      end
      if count_timestamps != 0
        average_timestamp = sum_timestamp / count_timestamps
        return {:power => result/1000, :timestamp => average_timestamp}
      end
      return {:power => 0, :timestamp => 0}
    else
      last_reading = Reading.last_by_metering_point_id(self.id)
      if last_reading && last_reading[:power]
        {:power => last_reading[:power]/1000, :timestamp => last_reading[:timestamp].to_i*1000}
      else
        {:power => 0, :timestamp => 0}
      end

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

  def slp?
    self.input? && !self.smart?
  end

  def pv?
    self.output? && !self.smart? && self.devices.any? && self.devices.first.primary_energy == 'sun'
  end

  def bhkw_or_else?
    self.output? && !self.smart?
  end

  def fake_source
    if self.slp?
      "slp"
    elsif self.pv?
      "sep_pv"
    elsif self.bhkw_or_else?
      "sep_bhkw"
    end
  end




  def addable_devices
    @users = []
    @users << self.users
    @users << User.with_role(:manager, self)
    (@users).flatten.uniq.collect{|user| user.editable_devices.collect{|device| device if device.mode == self.mode} }.flatten.compact
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


  def self.update_cache
    MeteringPoint.all.select(:id).each.each do |metering_point|

      # Sidekiq::Client.push({
      #  'class' => UpdateMeteringPointChartCache,
      #  'queue' => :default,
      #  'args' => [ metering_point.id, 'day_to_minutes']
      # })

      Sidekiq::Client.push({
       'class' => UpdateMeteringPointChartCache,
       'queue' => :default,
       'args' => [ metering_point.id, 'day_to_hours']
      })

      # Sidekiq::Client.push({
      #  'class' => UpdateMeteringPointLatestFakeDataCache,
      #  'queue' => :default,
      #  'args' => [ metering_point.id]
      # })

      # Sidekiq::Client.push({
      #  'class' => UpdateMeteringPointLatestPowerCache,
      #  'queue' => :default,
      #  'args' => [ metering_point.id]
      # })

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
      result += formula_part.operator + " " + formula_part.operand_id.to_s + " "
    end
    return result
  end

  def get_operands_from_formula
    if self.virtual && self.formula_parts.any?
      self.formula_parts.collect(&:operand_id)
    end
  end



  def calculate_forecast(containing_timestamp)
    if smart?
      return
    end
    readings = Reading.all_by_metering_point_id(self.id)
    if readings.size > 1
      last_timestamp = readings.last[:timestamp].to_i
      last_value = readings.last[:watt_hour]/10000000000.0
      another_timestamp = readings[readings.size - 2][:timestamp].to_i
      another_value = readings[readings.size - 2][:watt_hour]/10000000000.0
      i = 3
      while last_timestamp - another_timestamp < 2592000 do # difference must at least be 30 days = 2592000 seconds
        if i > readings.size
          return
        end
        another_timestamp = readings[readings.size - i][:timestamp].to_i
        another_value = readings[readings.size - i][:watt_hour]/10000000000.0
        i += 1
      end
      if last_timestamp - another_timestamp >= 2592000
        count_days_in_year = (Time.at(last_timestamp).end_of_year - Time.at(last_timestamp).beginning_of_year)/(3600*24)
        count_past_days = ((Time.at(last_timestamp) - Time.at(another_timestamp))/3600/24).to_i
        count_watt_hour = last_value - another_value
        yearly_consumption = (count_watt_hour / (count_past_days * 1.0)) * count_days_in_year

        self.forecast_kwh_pa = yearly_consumption
        self.save
      end

    end
  end


  def get_operators_from_formula
    if self.virtual && self.formula_parts.any?
      self.formula_parts.collect(&:operator)
    end
  end


  def chart_data(resolution_format, containing_timestamp)
    if self.virtual && self.formula
      operands_plus = FormulaPart.where(metering_point_id: self.id).where(operator: "+").collect(&:operand)
      operands_minus = FormulaPart.where(metering_point_id: self.id).where(operator: "-").collect(&:operand)
      data = []
      data << convert_to_array_build_timestamp(Reading.aggregate(resolution_format, operands_plus.collect(&:id), containing_timestamp), resolution_format, containing_timestamp)
      if operands_minus.any?
        data << convert_to_array_build_timestamp(Reading.aggregate(resolution_format, operands_minus.collect(&:id), containing_timestamp), resolution_format, containing_timestamp)
        operators = ["+", "-"]
        return calculate_virtual_metering_point(data, operators, resolution_format)
      else
        return data[0]
      end
    else
      fake_or_smart(self.id, resolution_format, containing_timestamp)
    end
  end


  def fake_or_smart(metering_point_id, resolution_format, containing_timestamp)
    metering_point = MeteringPoint.find(metering_point_id)
    if metering_point.meter && metering_point.meter.smart
      convert_to_array(Reading.aggregate(resolution_format, [metering_point.id], containing_timestamp), resolution_format, 1) # smart
    else
      if self.pv?
        convert_to_array(Reading.aggregate(resolution_format, ['sep_pv'], containing_timestamp), resolution_format, forecast_kwh_pa.nil? ? 1 : forecast_kwh_pa/1000.0) # SEP
      elsif self.bhkw_or_else?
        convert_to_array(Reading.aggregate(resolution_format, ['sep_bhkw'], containing_timestamp), resolution_format, forecast_kwh_pa.nil? ? 1 : forecast_kwh_pa/1000.0) # SEP
      elsif self.slp?
        convert_to_array(Reading.aggregate(resolution_format, ['slp'], containing_timestamp), resolution_format, forecast_kwh_pa.nil? ? 1 : forecast_kwh_pa/1000.0) # SLP
      end
    end
  end


  def latest_fake_data
    if self.slp?
      return {data: Reading.latest_fake_data('slp'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    elsif self.pv?
      return {data: Reading.latest_fake_data('sep_pv'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    elsif self.bhkw_or_else?
      return {data: Reading.latest_fake_data('sep_bhkw'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    end
  end


end
















