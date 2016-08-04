class MeteringPoint < ActiveRecord::Base
  resourcify
  acts_as_commentable
  include Authority::Abilities
  include CalcVirtualMeteringPoint
  include ChartFunctions
  include Filterable

  include PublicActivity::Model
  tracked except: :update, owner: Proc.new{ |controller, model| controller && controller.current_user }, recipient: Proc.new{ |controller, model| controller && model }


  belongs_to :group
  belongs_to :meter

  has_many :formula_parts, dependent: :destroy
  accepts_nested_attributes_for :formula_parts, reject_if: :all_blank, :allow_destroy => true

  has_many :contracts, dependent: :destroy
  has_many :devices
  has_one :address, as: :addressable, dependent: :destroy

  has_many :scores, as: :scoreable

  has_many :members, -> { where roles:  { name: 'member'} }, through: :roles, source: :users
  has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users

  accepts_nested_attributes_for :meter
  accepts_nested_attributes_for :contracts

  validates :readable, presence: true
  validates :mode, presence: true#, if: :no_dashboard_metering_point?
  validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
  validates :name, presence: true, length: { in: 2..30 }#, if: :no_dashboard_metering_point?
  validates :meter, presence: false, if: :virtual

  mount_uploader :image, PictureUploader

  before_destroy :delete_meter
  before_destroy :destroy_content

  has_many :dashboard_metering_points
  has_many :dashboards, :through => :dashboard_metering_points

  default_scope { order('name ASC') } #DESC

  scope :inputs, -> { where(mode: :in) }
  scope :outputs, -> { where(mode: :out) }

  scope :non_privates, -> { where("readable in (?)", ["world", "community", "friends"]) }
  scope :privates, -> { where("readable in (?)", ["members"]) }

  scope :without_group, lambda { self.where(group: nil) }
  scope :without_meter, lambda { self.where(meter: nil) }
  scope :with_meter, lambda { self.where.not(meter: nil) }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  def self.search_attributes
    [:name, address: [:city, :state, :street_name]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

  scope :accessible_by_user, lambda {|user|
    self.with_role([:manager, :member], user).distinct
  }

  scope :editable_by_user_without_meter_not_virtual, lambda {|user|
    self.with_role(:manager, user).where(meter: nil).where(virtual: false)
  }

  scope :by_group, lambda {|group|
    self.where(group: group.id)
  }

  scope :externals, -> { where(external: true) }
  scope :without_externals, -> { where(external: false) }

  #default_scope { where(external: false) }

  def users
    members + managers
  end

  def profiles
    Profile.where(user_id: users.collect(&:id))
  end

  def dashboard
    if self.is_dashboard_metering_point
      self.dashboards.collect{|d| d if d.dashboard_metering_points.include?(self)}.first
    end
  end

  def existing_group_request
    GroupMeteringPointRequest.where(metering_point_id: self.id).first
  end

  def received_user_requests
    MeteringPointUserRequest.where(metering_point: self).requests
  end

  def in_localpool?
    self.group && self.group.mode == "localpool"
  end

  # TODO remove this when bubbles.js is rewritten
  def last_power
    if self.virtual && self.formula_parts.any?
      operands = get_operands_from_formula
      operators = get_operators_from_formula
      result = 0
      i = 0
      count_timestamps = 0
      sum_timestamp = 0
      operands.each do |metering_point|
        reading = metering_point.last_power
        if !reading.nil? #&& reading[:timestamp] >= Time.now - 1.hour
          if operators[i] == "+"
            result += reading[:power]
          elsif operators[i] == "-"
            result -= reading[:power]
          end
          sum_timestamp += reading[:timestamp].to_i*1000
          count_timestamps += 1
        else
          return {:power => 0, :timestamp => 0}
        end
        i+=1
      end
      if count_timestamps != 0
        average_timestamp = sum_timestamp / count_timestamps
        return {:power => result, :timestamp => average_timestamp/1000}
      end
      return {:power => 0, :timestamp => 0}
    elsif self.smart?
      crawler = Crawler.new(self)
      return crawler.live
    else
      result = self.latest_fake_data
      if result[:data].nil?
        return { :power => 0, :timestamp => Time.now.to_i*1000}
      end
      return { :power => result[:data].flatten[1] * result[:factor], :timestamp => result[:data].flatten[0]}
    end
  end

  # TODO remove this
  def latest_fake_data
    if self.slp?
      return {data: Reading.latest_fake_data('slp'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    elsif self.pv?
      return {data: Reading.latest_fake_data('sep_pv'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    elsif self.bhkw_or_else?
      return {data: Reading.latest_fake_data('sep_bhkw'), factor: self.forecast_kwh_pa.nil? ? 1 : self.forecast_kwh_pa/1000.0}
    else
      return {data: [[0, 1]], factor: 1}
    end
  end

  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_world?
    self.readable == 'world'
  end

  def readable_by_members?
    self.readable == 'members'
  end

  def readable_by_community?
    self.readable == 'community'
  end


  # TODO move this to decorater
  def readable_icon
    if readable_by_friends?
      "user-plus"
    elsif readable_by_world?
      "globe"
    elsif readable_by_members?
      "key"
    elsif readable_by_community?
      "users"
    end
  end


  def involved
    (self.managers + self.members).uniq
  end

  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def smart?
    if self.virtual
      self.formula_parts.each do |formula_part|
        if !formula_part.operand.smart?
          return false
        end
      end
      return true
    else
      if meter
        return meter.smart
      end
      return false
    end
  end


  # TODO remove this
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
    !self.smart? &&
    self.input?
  end

  def pv?
    !self.smart? &&
    self.output? &&
    self.devices.any? &&
    self.devices.first.primary_energy == 'sun'
  end

  def bhkw_or_else?
    !self.smart? &&
    self.output?
  end

  def mysmartgrid?
    self.smart? &&
    !metering_point_operator_contract.nil? &&
    metering_point_operator_contract.organization.slug == "mysmartgrid"
  end

  def discovergy?
    self.smart? &&
    !metering_point_operator_contract.nil? &&
    (metering_point_operator_contract.organization.slug == "discovergy" ||
    metering_point_operator_contract.organization.slug == "buzzn-metering")
  end

  def buzzn_api?
    self.smart? &&
    metering_point_operator_contract.nil?
  end

  def data_source
    if self.virtual?
      "virtual"
    elsif self.slp?
      "slp"
    elsif self.pv?
      "sep_pv"
    elsif self.bhkw_or_else?
      "sep_bhkw"
    elsif self.mysmartgrid?
      "mysmartgrid"
    elsif self.discovergy?
      "discovergy"
    elsif self.buzzn_api?
      "buzzn_api"
    end
  end




  def addable_devices
    @users = []
    @users << members
    @users << manager
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
    }
  end

  def self.readables
    %w{
      world
      community
      friends
      members
    }
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
    chart_data('minute_to_seconds', containing_timestamp)
  end

  def hour_to_minutes(containing_timestamp)
    chart_data('hour_to_minutes', containing_timestamp)
  end

  def day_to_hours(containing_timestamp)
    chart_data('day_to_hours', containing_timestamp)
  end

  def day_to_minutes(containing_timestamp)
    chart_data('day_to_minutes', containing_timestamp)
  end

  def week_to_days(containing_timestamp)
    chart_data('week_to_days', containing_timestamp)
  end

  def month_to_days(containing_timestamp)
    chart_data('month_to_days', containing_timestamp)
  end

  def year_to_months(containing_timestamp)
    chart_data('year_to_months', containing_timestamp)
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
      self.formula_parts.collect(&:operand)
    end
  end



  def calculate_forecast
    if smart?
      return
    end
    readings = Reading.all_by_meter_id(self.meter.id)
    if readings.size > 1
      last_timestamp = readings.last[:timestamp].to_i
      last_value = readings.last[:energy_a_milliwatt_hour]/1000000.0
      another_timestamp = readings[readings.size - 2][:timestamp].to_i
      another_value = readings[readings.size - 2][:energy_a_milliwatt_hour]/1000000.0
      i = 3
      while last_timestamp - another_timestamp < 2592000 do # difference must at least be 30 days = 2592000 seconds
        if i > readings.size
          return
        end
        another_timestamp = readings[readings.size - i][:timestamp].to_i
        another_value = readings[readings.size - i][:energy_a_milliwatt_hour]/1000000.0
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



  def self.observe
    MeteringPoint.where("observe = ? OR observe_offline = ?", true, true).each do |metering_point|
      Sidekiq::Client.push({
       'class' => MeteringPointObserveWorker,
       'queue' => :default,
       'args' => [metering_point.id]
      })
    end
  end


  def self.calculate_scores
    MeteringPoint.all.select(:id, :mode).each.each do |metering_point|
      if metering_point.input?
        Sidekiq::Client.push({
         'class' => CalculateMeteringPointScoreSufficiencyWorker,
         'queue' => :default,
         'args' => [ metering_point.id, 'day', Time.now.to_i*1000]
        })

        Sidekiq::Client.push({
         'class' => CalculateMeteringPointScoreFittingWorker,
         'queue' => :default,
         'args' => [ metering_point.id, 'day', Time.now.to_i*1000]
        })
      end
    end
  end


  def get_operators_from_formula
    if self.virtual && self.formula_parts.any?
      self.formula_parts.collect(&:operator)
    end
  end


  def submitted_readings_by_user
    if self.data_source
      Reading.all_by_metering_point_id(self.id)
    end
  end

  private

    def delete_meter
      if self.meter
        if self.meter.metering_points.size == 1
          self.meter.destroy
        end
      end
      FormulaPart.where(operand_id: self.id).each do |formula_part|
        formula_part.destroy
      end
    end

    def destroy_content
      MeteringPointUserRequest.where(metering_point: self).each{|request| request.destroy}
      GroupMeteringPointRequest.where(metering_point: self).each{|request| request.destroy}
      self.root_comments.each{|comment| comment.destroy}
      #self.activities.each{|activity| activity.destroy}
    end
end
