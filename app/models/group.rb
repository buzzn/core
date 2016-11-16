require 'buzzn/guarded_crud'
require 'buzzn/score_calculator'
class Group < ActiveRecord::Base
  resourcify
  acts_as_commentable
  include Authority::Abilities
  include CalcVirtualRegister
  include ChartFunctions
  include Filterable
  include ReplacableRoles
  include Buzzn::GuardedCrud

  before_destroy :destroy_content

  include PublicActivity::Model
  tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked  recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :finders]


  validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

  normalize_attribute :name, with: [:strip]

  mount_uploader :logo, PictureUploader
  #mount_uploader :image, PictureUploader
  mount_base64_uploader :image, PictureUploader

  has_many :contracts, dependent: :destroy
  has_one  :area
  has_many :registers

  has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users

  has_many :scores, as: :scoreable

  # validates :registers, presence: true

  after_save :validate_localpool

  normalize_attributes :description, :website

  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :members_of_group, ->(group) do
    mp = Register.arel_table
    roles = Role.arel_table
    users_roles = Arel::Table.new(:users_roles)
    users = User.arel_table

    users_on = users.create_on(users_roles[:user_id].eq(users[:id]))
    users_join = users.create_join(users_roles, users_on)

    users_roles_on = users_roles.create_on(roles[:id].eq(users_roles[:role_id]))
    users_roles_join = users_roles.create_join(roles, users_roles_on)

    roles_register_on = roles.create_on(roles[:resource_id].eq(mp[:id]).and(roles[:resource_type].eq(Register.to_s).and(roles[:name].eq(:member))))
    roles_register_join = roles.create_join(mp, roles_register_on)


    User.distinct
      .joins(users_join, users_roles_join, roles_register_join)
      .where('registers.group_id': group)
  end

  # keeps this notation so it can be chained with Arel table where clauses
  scope :readable_by_world, -> { where("groups.readable = 'world'") }

  scope :readable_by, ->(user) do
    if user.nil?
      readable_by_world
    else
      # world or community query
      group = Group.arel_table
      world_or_community = group[:readable].in(['world','community'])

      # admin or manager or member query
      register = Register.arel_table
      admin_or_manager_or_member = User.roles_query(user, manager: group[:id], member: register.alias[:id], admin: nil).project(1).exists

      # friends of manager and member of register
      register_friends = Friendship.friend_of_roles_query(user, register.alias, :member, :manager).and(group[:readable].eq('friends'))

      # friends of manager of group
      manager_friends = Friendship.friend_of_roles_query(user, group, :manager).and(group[:readable].eq('friends'))

      sqls = [
        world_or_community,
        admin_or_manager_or_member,
        register_friends,
        manager_friends
      ]

      # with AR5 you can use left_outer_joins directly
      # `left_outer_joins(:registers)` instead of
      # this register_on and register_join
      register_on   = register.create_on(group[:id].eq(register.alias[:group_id]))
      register_join = register.create_join(register.alias, register_on, Arel::Nodes::OuterJoin)

      joins(register_join).where(sqls.map(&:to_sql).join(' OR '))
    end
  end

  def self.search_attributes
    [:name, :description]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

  # TODO remove this
  def self.search(search)
    if search
      where('name ILIKE ? or slug ILIKE ?', "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def self.accessible_by_user(user)
    register = Register.arel_table
    group          = Group.arel_table
    users          = User.roles_query(user, manager: [group[:id], register[:id]], member: register[:id])

    # need to make join manually to get the reference name right
    register_on   = group.create_on(group[:id].eq(register[:group_id]))
    register_join = group.create_join(register, register_on)
    joins(register_join).where(users.project(1).exists)
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def register_users_query(mode = nil)
    mp             = Register.arel_table
    roles          = Role.arel_table
    users_roles    = Arel::Table.new(:users_roles)
    users          = User.arel_table
    role_names     = [:manager, :member]

    register_on = mp[:group_id].eq(self.id)
    register_on = register_on.and(mp[:mode].eq(mode)) if mode
    users_roles.join(mp)
      .on(register_on)
      .join(roles)
      .on(roles[:id].eq(users_roles[:role_id])
           .and(roles[:name].in(role_names).and(roles[:resource_id].eq(mp[:id]))))
      .where(users_roles[:user_id].eq(users[:id]))
  end

  def energy_producers
    User.where(register_users_query('in').project(1).exists.to_sql)
  end

  def energy_consumers
    User.where(register_users_query('out').project(1).exists.to_sql)
  end

  def member?(register)
    self.registers.include?(register) ? true : false
  end

  def involved
    managers = User.roles_query(nil, manager: self).project(1).exists.to_sql
    register_users = register_users_query.project(1).exists.to_sql
    User.where([managers, register_users].join(' OR '))
  end

  def members
    self.class.members_of_group(self)
  end

  def in_registers
    Register.where(group: self).where(mode: 'in')
  end

  def out_registers
    Register.where(group: self).where(mode: 'out')
  end


  def received_group_register_requests
    GroupRegisterRequest.where(group: self).requests
  end

  def keywords
    %w(buzzn people power) << self.name
  end

  def self.readables
    %w{
      world
      community
      friends
      members
    }
  end

  def self.modes
    %w(localpool public_group)
  end

  def readable_by_members?
    self.readable == 'members'
  end

  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_community?
    self.readable == 'community'
  end

  def readable_by_world?
    self.readable == 'world'
  end

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

  def self.readable_group_ids_by_user(user)
    group_ids = Group.all.readable_by_world.ids
    if user.nil?
      return group_ids
    else
      group_ids << Group.where(readable: 'community').collect(&:id)
      group_ids << Group.with_role(:manager, user).collect(&:id)
      group_ids << user.accessible_registers.collect(&:group).compact.collect(&:id)

      user.friends.each do |friend|
        if friend
          Group.where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
            group_ids << friend_group.id
          end
        end
      end
      return group_ids.compact.flatten.uniq
    end
  end

  def calculate_total_energy_data(data, operators, resolution)
    calculate_virtual_register(data, operators, resolution)
  end

  def chart(resolution_format, containing_timestamp=nil)
    if containing_timestamp == nil
      containing_timestamp = Time.current.to_i * 1000
    end

    data_in = []
    data_out = []

    registers_in = self.registers.without_externals.where(mode: 'in')
    registers_out = self.registers.without_externals.where(mode: 'out')
    operators = []
    registers_in.each do |register|
      data_in << register.chart_data(resolution_format, containing_timestamp)
      operators << "+"
    end
    result_in = calculate_virtual_register(data_in, operators, resolution_format)

    operators = []

    registers_out.each do |register|
      data_out << register.chart_data(resolution_format, containing_timestamp)
      operators << "+"
    end
    result_out = calculate_virtual_register(data_out, operators, resolution_format)

    #TODO: Aus irgend einem Grund gibt es bei manchen Gruppen einen falschen Zeitstempel
    if resolution_format == 'month_to_days'
      i = 0
      while i < result_in.size do
        if Time.at(result_in[i][0]/1000).in_time_zone.hour != 0
          result_in.delete_at(i)
        end
        i+=1
      end
      i = 0
      while i < result_out.size do
        if Time.at(result_out[i][0]/1000).in_time_zone.hour != 0
          result_out.delete_at(i)
        end
        i+=1
      end
    end

    return [ { :name => I18n.t('total_consumption'), :data => result_in}, { :name => I18n.t('total_production'), :data => result_out} ]
  end


  def chart_without_discovergy(resolution_format, containing_timestamp=nil)
    registers_in_plus = []
    registers_in_minus = []
    registers_out_plus = []
    registers_out_minus = []
    self.registers.without_externals.each do |register|
      if register.virtual
        if register.input?
          register.formula_parts.where(operator: "+").collect(&:operand).each do |register_plus|
            registers_in_plus << register_plus.id
          end
          register.formula_parts.where(operator: "-").collect(&:operand).each do |register_minus|
            registers_in_minus << register_minus.id
          end
        else
          register.formula_parts.where(operator: "+").collect(&:operand).each do |register_plus|
            registers_out_plus << register_plus.id
          end
          register.formula_parts.where(operator: "-").collect(&:operand).each do |register_minus|
            registers_out_minus << register_minus.id
          end
        end
      else
        if register.input?
          registers_in_plus << register.id
        else
          registers_out_plus << register.id
        end
      end
    end

    if containing_timestamp == nil
      containing_timestamp = Time.current.to_i * 1000
    end

    data_in = []
    data_out = []
    operators = ["+", "-"]
    data_in << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, registers_in_plus, containing_timestamp), resolution_format, containing_timestamp)
    if registers_in_minus.any?
      data_in << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, registers_in_minus, containing_timestamp), resolution_format, containing_timestamp)
      result_in = calculate_virtual_register(data_in, operators, resolution_format)
    else
      result_in = data_in[0]
    end
    data_out << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, registers_out_plus, containing_timestamp), resolution_format, containing_timestamp)
    if registers_out_minus.any?
      data_out << self.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, registers_out_minus, containing_timestamp), resolution_format, containing_timestamp)
      result_out = calculate_virtual_register(data_out, operators, resolution_format)
    else
      result_out = data_out[0]
    end
    return [ { :name => I18n.t('total_consumption'), :data => result_in}, { :name => I18n.t('total_production'), :data => result_out} ]
  end

  def self.score_interval(resolution_format, containing_timestamp)
    if resolution_format == 'year_to_minutes' || resolution_format == 'year'
      return ['year', Time.at(containing_timestamp).in_time_zone.beginning_of_year, Time.at(containing_timestamp).in_time_zone.end_of_year]
    elsif resolution_format == 'month_to_minutes' || resolution_format == 'month'
      return ['month', Time.at(containing_timestamp).in_time_zone.beginning_of_month, Time.at(containing_timestamp).in_time_zone.end_of_month]
    elsif resolution_format == 'day_to_minutes' || resolution_format == 'day'
      return ['day', Time.at(containing_timestamp).in_time_zone.beginning_of_day, Time.at(containing_timestamp).in_time_zone.end_of_day]
    end
  end
  def set_score_interval(resolution_format, containing_timestamp)
    self.class.score_interval(resolution_format, containing_timestamp)
  end
  alias :get_score_interval :set_score_interval

  def extrapolate_kwh_pa(kwh_ago, resolution_format, containing_timestamp)
    days_ago = 0
    if resolution_format == 'year'
      if Time.at(containing_timestamp).end_of_year < Time.current
        days_ago = 365
      else
        days_ago = ((Time.current - Time.current.beginning_of_year)/(3600*24.0)).to_i
      end
    elsif resolution_format == 'month'
      if Time.at(containing_timestamp).end_of_month < Time.current
        days_ago = Time.at(containing_timestamp).days_in_month
      else
        days_ago = Time.current.day
      end
    elsif resolution_format == 'day'
      if Time.at(containing_timestamp).in_time_zone.end_of_day < Time.current
        days_ago = 1
      else
        days_ago = (Time.current - Time.current.beginning_of_day)/(3600*24.0)
      end
    end
    return kwh_ago / (days_ago*1.0) * 365
  end


  def self.update_cache
    Group.all.select(:id).each.each do |group|
      Sidekiq::Client.push({
       'class' => UpdateGroupChartCache,
       'queue' => :default,
       'args' => [ group.id, 'day_to_minutes']
      })
    end
  end

  def self.calculate_scores
    Sidekiq::Client.push({
     'class' => CalculateGroupScoresWorker,
     'queue' => :default,
     'args' => [ (Time.current - 1.day).to_i ]
    })
  end

  def calculate_scores(containing_timestamp)
    Buzzn::ScoreCalculator.new(self, containing_timestamp).calculate_all_scores
  end

  def calculate_current_closeness
    addresses_out = self.registers.without_externals.outputs.collect(&:address).compact
    addresses_in = self.registers.without_externals.inputs.collect(&:address).compact
    sum_distances = 0
    addresses_in.each do |address_in|
      addresses_out.each do |address_out|
        sum_distances += address_in.distance_to(address_out)
      end
    end
    closeness = -1
    if addresses_out.count * addresses_in.count != 0
      average_distance = sum_distances / (addresses_out.count * addresses_in.count)
      if average_distance < 5
        closeness = 5
      elsif average_distance < 10
        closeness = 4
      elsif average_distance < 20
        closeness = 3
      elsif average_distance < 50
        closeness = 2
      elsif average_distance < 200
        closeness = 1
      elsif average_distance >= 200
        closeness = 0
      end
    end
    return closeness
  end

  def bubbles_personal_data(requesting_user)
    out_register_personal_data = []
    in_register_personal_data = []
    self.registers.without_externals.each do |register|
      register_name = register.decorate.name_with_users
      if register.involved.any?
        if register.involved.include?(requesting_user)
          own_register = true
        else
          own_register = false
        end
      else
        own_register = false
      end
      readable = requesting_user.nil? ? false : register.readable_by?(requesting_user)
      if !readable
        register_name = "anonym"
      end
      personal_data_entry = {:register_id => register.id, :name => register_name, :own_register => own_register, :readable => readable}
      if register.mode == 'out'
        out_register_personal_data.push(personal_data_entry)
      else
        in_register_personal_data.push(personal_data_entry)
      end
    end
    personal_data = {:in => in_register_personal_data, :out => out_register_personal_data}
    return personal_data
  end

  def get_scores(resolution, containing_timestamp)
    if resolution.nil?
      resolution = "year_to_months"
    end
    if containing_timestamp.nil?
      containing_timestamp = Time.current.to_i * 1000
    end

    if resolution == 'day_to_minutes'
      sufficiency = self.scores.sufficiencies.dayly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.dayly.at(containing_timestamp).first
      fitting = self.scores.fittings.dayly.at(containing_timestamp).first
      closeness = self.scores.closenesses.dayly.at(containing_timestamp).first
    elsif resolution == 'month_to_days'
      sufficiency = self.scores.sufficiencies.monthly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.monthly.at(containing_timestamp).first
      fitting = self.scores.fittings.monthly.at(containing_timestamp).first
      closeness = self.scores.closenesses.monthly.at(containing_timestamp).first
    elsif resolution == 'year_to_months'
      sufficiency = self.scores.sufficiencies.yearly.at(containing_timestamp).first
      autarchy = self.scores.autarchies.yearly.at(containing_timestamp).first
      fitting = self.scores.fittings.yearly.at(containing_timestamp).first
      closeness = self.scores.closenesses.yearly.at(containing_timestamp).first
    end
    sufficiency.nil? ? sufficiency_value = -1 : sufficiency_value = sufficiency.value
    autarchy.nil? ? autarchy_value = -1 : autarchy_value = autarchy.value
    fitting.nil? ? fitting_value = -1 : fitting_value = fitting.value
    closeness.nil? ? closeness_value = -1 : closeness_value = closeness.value
    return { sufficiency: sufficiency_value, closeness: closeness_value, autarchy: autarchy_value, fitting: fitting_value }
  end


  private

    def destroy_content
      self.registers.each do |register|
        register.group = nil
        register.save
        register.meter.save if register.meter
      end
      GroupRegisterRequest.where(group: self).each{|request| request.destroy}
      self.root_comments.each{|comment| comment.destroy}
    end

    def validate_localpool
      if self.mode == 'localpool'
        if self.contracts.register_operators.empty?
          @contract = Contract.new(mode: 'register_operator_contract', price_cents: 0, group: self, organization: Organization.buzzn_metering, username: 'team@localpool.de', password: 'Zebulon_4711')
        else
          @contract = self.contracts.register_operators.first
        end
        @contract.save
      else
        if self.contracts.any?
          self.contracts.each do |contract|
            contract.delete
            #contract.save
          end
        end
      end
    end
end
