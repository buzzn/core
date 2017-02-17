

require 'buzzn/managed_roles'
module Register
  class Base < ActiveRecord::Base
    self.table_name = :registers
    resourcify
    include Authority::Abilities
    include CalcVirtualRegister
    include ChartFunctions
    include Filterable
    include Buzzn::ManagerRole
    include Buzzn::MemberRole
    include Buzzn::GuardedCrud
    include PublicActivity::Model

    def self.after_create_callback(user, obj)
      obj.create_activity(key: 'register.create', recipient: obj, owner: user)
    end

    def self.after_destroy_callback(user, obj)
      obj.create_activity(trackable: nil, key: 'register.destroy', recipient: nil, owner: user)
    end

    belongs_to :group

    has_many :contracts, class_name: Contract::Base, dependent: :destroy, foreign_key: 'register_id'
    has_many :devices, foreign_key: 'register_id'
    has_one :address, as: :addressable, dependent: :destroy

    has_many :scores, as: :scoreable

    # TODO ???
    accepts_nested_attributes_for :contracts

    def brokers
      Broker::Base.where(resource_id: self.meter.id, resource_type: Meter::Base)
    end

    def self.readables
      %w{
      world
      community
      friends
      members
    }
    end

    def self.directions; %w(in out); end

    validates :meter, presence: true
    validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
    validates :name, presence: true, length: { in: 2..30 }#, if: :no_dashboard_register?
    # TODO virtual register ?
    validates :image, presence: false
    validates :voltage_level, presence: false
    validates :regular_reeding, presence: false
    validates :regular_interval, presence: false
    validates :is_dashboard_register, presence: false
    validates :readable, inclusion: { in: self.readables }
    validates :forecast_kwh_pa, presence: false, numericality: true, allow_nil: true
    validates :observe, presence: false
    validates :min_watt, presence: false
    validates :max_watt, presence: false
    validates :last_observed_timestamp, presence: false
    # TODO virtual register ?
    validates :observe_offline, presence: false
    validates :external, presence: false

    def discovergy_brokers
      raise 'TODO use brokers method instead'
    end

    validate :validate_invariants

    mount_uploader :image, PictureUploader

    before_destroy :destroy_content

    has_many :dashboard_registers
    has_many :dashboards, :through => :dashboard_registers

    scope :inputs, -> { where(type: Register::Input) }
    scope :outputs, -> { where(type: Register::Output) }

    scope :non_privates, -> { where("readable in (?)", ["world", "community", "friends"]) }
    scope :privates, -> { where("readable in (?)", ["members"]) }

    scope :without_group, lambda { self.where(group: nil) }
    scope :without_meter, lambda { raise 'FIXME' }
    scope :with_meter, lambda { raise 'FIXME' }

    scope :editable_by_user, lambda {|user|
      self.with_role(:manager, user)
    }

    def self.search_attributes
      [:name, address: [:city, :state, :street_name]]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

    # replaces the name with 'anonymous' for all registers which are
    # not readable_by without delegating the check to the underlying group
    scope :anonymized, -> (user) do
      cols = Register::Base.columns.collect {|c| c.name }.reject{|c| c == 'name'}.join(', ')
      sql = Register::Base.readable_by(user, false).select("id").to_sql
      select("#{cols}, CASE WHEN id NOT IN (#{sql}) THEN 'anonymous' ELSE name END AS name")
    end

    scope :anonymized_readable_by, ->(user) do
      readable_by(user, true).anonymized(user)
    end

    scope :readable_by, ->(user, group_check = true) do
      register = Register::Base.arel_table
      sqls = []
      if group_check
        # register belongs to readable group
        group = Group.arel_table
        belongs_to_readable_group = Group.readable_by(user).where(group[:id].eq(register[:group_id]))
        # sql fragment 'exists select 1 where .....'
        sqls << belongs_to_readable_group.project(1).exists
      end
      if user.nil?
        sqls << register[:readable].eq('world')
      else
        # world or community query
        world_or_community = register[:readable].in(['world','community'])

        # admin or manager or member query
        admin_or_manager_or_member = User.roles_query(user, manager: register[:id], member: register[:id], admin: nil)

        # friends of manager query
        manager_friends = Friendship.friend_of_roles_query(user, register, :manager)

        sqls +=
          [
            # sql fragment 'exists select 1 where .....'
            admin_or_manager_or_member.project(1).exists,
            # friends of managers needs register to be readable by friends
            manager_friends.and(register[:readable].eq('friends')),
            world_or_community
          ]
      end
      where(sqls.map(&:to_sql).join(' OR '))
    end

    #TODO why is this less strikt than the readable_by definition ?
    #     what is the difference between accessible_by and readable_by ?
    scope :accessible_by_user, ->(user) do
      register = Register::Base.arel_table
      where(User.roles_query(user,
                             manager: register[:id],
                             member: register[:id]).project(1).exists)
    end

    # TODO
    scope :editable_by_user_without_meter_not_virtual, lambda {|user|
      raise 'FIXME'
    }

    scope :by_group, lambda {|group|
      group ? self.where(group: group.id) : self.where('1=2')
    }

    scope :externals, -> { where(external: true) }
    scope :without_externals, -> { where(external: false) }

    def validate_invariants
      # TODO: add this when migration were running
      # if contracts.size > 0 && address.nil?
      #   errors.add(:address, 'missing Address when having contracts')
      # end
      if max_watt < min_watt
        errors.add(:max_watt, 'must be greater or equal min_watt')
        errors.add(:min_watt, 'must be smaller or equal max_watt')
      end
    end

    def direction
      case self
      when Register::Input
        :in
      when Register::Output
        :out
      else
        self.mode.to_sym
      end
    end

    def users
      User.users_of(self, :manager, :member)
    end
    alias :involved :users

    def profiles
      Profile.where(user_id: users)
    end

    def dashboard
      if self.is_dashboard_register
        self.dashboards.collect{|d| d if d.dashboard_registers.include?(self)}.first
      end
    end

    def existing_group_request
      GroupRegisterRequest.where(register_id: self.id).first
    end

    def received_user_requests
      RegisterUserRequest.where(register: self).requests
    end

    def in_localpool?
      self.group && self.group.mode == "localpool"
    end

    # TODO remove this when bubbles.js is rewritten
    # TODO still used ?
    def last_power
      if self.virtual && self.formula_parts.any?
        operands = get_operands_from_formula
        operators = get_operators_from_formula
        result = 0
        i = 0
        count_timestamps = 0
        sum_timestamp = 0
        operands.each do |register|
          reading = register.last_power
          if !reading.nil? #&& reading[:timestamp] >= Time.current - 1.hour
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
          return { :power => 0, :timestamp => Time.current.to_i*1000}
        end
        return { :power => result[:data].flatten[1] * result[:factor], :timestamp => result[:data].flatten[0]}
      end
    end

    # TODO remove this
    # still used ?
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


    def output?
      self.direction == :out
    end

    def input?
      self.direction == :in
    end

    def smart?
      self.meter.smart
    end

    def no_dashboard_register?
      !self.is_dashboard_register
    end

    # TODO remove with removing latest_fake_data
    def slp?
      !self.smart? &&
      self.input?
    end

    # TODO remove with removing latest_fake_data
    def pv?
      !self.smart? &&
      self.output? &&
      self.devices.any? &&
      self.devices.first.primary_energy == 'sun'
    end

    # TODO remove with removing latest_fake_data
    def bhkw_or_else?
      !self.smart? &&
      self.output?
    end

    def mysmartgrid?
      self.meter && self.meter.broker && self.meter.broker.is_a?(Broker::MySmartGrid)
    end

    def discovergy?
      self.meter && self.meter.broker && self.meter.broker.is_a?(Broker::Discovergy)
    end

    def buzzn_api?
      self.smart? &&
      metering_point_operator_contract.nil?
    end

    def data_source
      if self.discovergy?
        Buzzn::Discovergy::DataSource::NAME
      elsif self.mysmartgrid?
        Buzzn::MySmartGrid::DataSource::NAME
      else
        Buzzn::StandardProfile::DataSource::NAME
      end
    end




    def addable_devices
      @users = []
      @users << members
      @users << manager
      (@users).flatten.uniq.collect{|user| user.editable_devices.collect{|device| device if device.mode == self.mode} }.flatten.compact
    end

    # TODO remove as it is not used any more - was used in Crawler
    def metering_point_operator_contract
      if self.contracts.metering_point_operators.running.any?
        return self.contracts.metering_point_operators.running.first
      elsif self.group
        if self.group.contracts.metering_point_operators.running.any?
          return self.group.contracts.metering_point_operators.running.first
        end
      end
    end



    # TODO ????
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



    def calculate_forecast
      if smart?
        return
      end
      readings = Reading.all_by_register_id(self.id)
      if readings.size > 1
        last_timestamp = readings.last[:timestamp].to_i
        last_value = readings.last[:energy_milliwatt_hour]/1000000.0
        another_timestamp = readings[readings.size - 2][:timestamp].to_i
        another_value = readings[readings.size - 2][:energy_milliwatt_hour]/1000000.0
        i = 3
        while last_timestamp - another_timestamp < 2592000 do # difference must at least be 30 days = 2592000 seconds
          if i > readings.size
            return
          end
          another_timestamp = readings[readings.size - i][:timestamp].to_i
          another_value = readings[readings.size - i][:energy_milliwatt_hour]/1000000.0
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
      Sidekiq::Client.push({
         'class' => RegisterObserveWorker,
         'queue' => :default,
         'args' => []
        })
    end


    def self.calculate_scores
      Register::Base.all.select(:id, :mode).each.each do |register|
        if register.input?
          Sidekiq::Client.push({
           'class' => CalculateRegisterScoreSufficiencyWorker,
           'queue' => :default,
           'args' => [ register.id, 'day', Time.current.to_i*1000]
          })

          Sidekiq::Client.push({
           'class' => CalculateRegisterScoreFittingWorker,
           'queue' => :default,
           'args' => [ register.id, 'day', Time.current.to_i*1000]
          })
        end
      end
    end

    # TODO remove as it is unused
    def self.update_chart_cache
      Register::Base.ids.each do |register_id|
        Sidekiq::Client.push(
          'class' => UpdateRegisterChartCache,
          'queue' => :low,
          'args' => [register_id, Time.current, 'day_to_minutes']
          )
      end
    end


    # TODO remove this once app//controllers/registers_controller.rb is gone
    def submitted_readings_by_user
      if self.data_source
        Reading.all_by_register_id(self.id)
      end
    end

    def self.create_all_observer_activities
      where("observe = ? OR observe_offline = ?", true, true).each do |register|
        register.create_observer_activities rescue nil
      end
    end

    def create_observer_activities
      last_reading    = Buzzn::Application.config.current_power.for_register(self)
      if !last_reading
        return
      end

      # last readings are in milliwatt
      current_power = last_reading.value / 1000.0

      if Time.current.utc.to_i - last_reading.timestamp.to_i >= 5.minutes
        if observe_offline
          if Time.current.utc.to_i - last_reading.timestamp.to_i < 10.minutes
            return create_activity(key: 'register.offline', owner: self)
          end
        end
      else
        update(last_observed_timestamp: Time.at(last_reading.timestamp/1000.0).utc)
        if current_power < min_watt && current_power >= 0
          mode = 'undershoots'
        elsif current_power >= max_watt
          mode = 'exceeds'
        else
          mode = nil
        end
      end

      if observe && mode
        return create_activity(key: "register.#{mode}", owner: self)
      end
    end

    # for railsview
    def class_name
      self.class.name.downcase.sub!("::", "_")
    end

    # backward compatibility
    def direction=(val)
      self.mode = val
    end

    private

    def destroy_content
      RegisterUserRequest.where(register: self).each{|request| request.destroy}
      GroupRegisterRequest.where(register: self).each{|request| request.destroy}
      # TODO use delete_all ?
      self.root_comments.each{|comment| comment.destroy}
      self.activities.each{|activity| activity.destroy}
    end
  end
end
