require 'buzzn/guarded_crud'
require 'buzzn/score_calculator'
require 'buzzn/managed_roles'

module Group
  class Base < ActiveRecord::Base
    self.table_name = :groups
    resourcify
    acts_as_commentable
    include Authority::Abilities
    include CalcVirtualRegister
    include ChartFunctions
    include Filterable
    include Buzzn::ManagerRole
    include Buzzn::GuardedCrud

    before_destroy :destroy_content

    include PublicActivity::Model
    tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
    tracked  recipient: Proc.new{ |controller, model| controller && model }

    extend FriendlyId
    friendly_id :name, use: [:slugged, :history, :finders]

    def meters
      Meter::Base.where(
        Register::Base.where('registers.group_id = ? and registers.meter_id = meters.id', self)
          .select(1)
          .exists
        )
    end

    validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

    normalize_attribute :name, with: [:strip]

    mount_uploader :logo, PictureUploader
    #mount_uploader :image, PictureUploader

    has_one  :area
    has_many :registers, class_name: Register::Base, foreign_key: :group_id

    has_many :brokers, class_name: Broker::Base, as: :resource, :dependent => :destroy

    has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users

    has_many :scores, as: :scoreable

    # validates :registers, presence: true

    normalize_attributes :description, :website

    scope :editable_by_user, lambda {|user|
      self.with_role(:manager, user)
    }

    scope :members_of_group, ->(group) do
      mp = Register::Base.arel_table
      roles = Role.arel_table
      users_roles = Arel::Table.new(:users_roles)
      users = User.arel_table

      users_on = users.create_on(users_roles[:user_id].eq(users[:id]))
      users_join = users.create_join(users_roles, users_on)

      users_roles_on = users_roles.create_on(roles[:id].eq(users_roles[:role_id]))
      users_roles_join = users_roles.create_join(roles, users_roles_on)

      roles_register_on = roles.create_on(roles[:resource_id].eq(mp[:id]).and(roles[:name].eq(:member)))
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
        group = Group::Base.arel_table
        world_or_community = group[:readable].in(['world','community'])

        # admin or manager or member query
        register = Register::Base.arel_table
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
        joins(register_join).where('(' + sqls.map(&:to_sql).join(' OR ') + ')').distinct
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
      register       = Register::Base.arel_table
      group          = Group::Base.arel_table
      users          = User.roles_query(user, manager: [group[:id], register[:id]], member: register[:id])

      # need to make join manually to get the reference name right
      register_on   = group.create_on(group[:id].eq(register[:group_id]))
      register_join = group.create_join(register, register_on)
      joins(register_join).where(users.project(1).exists)
    end

    def should_generate_new_friendly_id?
      slug.blank? || name_changed?
    end

    def register_users_query(type = nil)
      mp             = Register::Base.arel_table
      roles          = Role.arel_table
      users_roles    = Arel::Table.new(:users_roles)
      users          = User.arel_table
      role_names     = [:manager, :member]

      register_on = mp[:group_id].eq(self.id)
      register_on = register_on.and(mp[:type].eq(type)) if type
      users_roles.join(mp)
        .on(register_on)
        .join(roles)
        .on(roles[:id].eq(users_roles[:role_id])
             .and(roles[:name].in(role_names).and(roles[:resource_id].eq(mp[:id]))))
        .where(users_roles[:user_id].eq(users[:id]))
    end

    def energy_producers
      User.where(register_users_query(Register::Output).project(1).exists.to_sql)
    end

    def energy_consumers
      User.where(register_users_query(Register::Input).project(1).exists.to_sql)
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

    def input_registers
      registers = Register::Base.arel_table
      Register::Base.where(
        registers[:group_id].eq(self.id).and(
          registers[:type].eq("Register::Input").or(
            registers[:type].eq("Register::Virtual").and(registers[:mode].eq('in')))
        )
      )
    end


    def output_registers
      registers = Register::Base.arel_table
      Register::Base.where(
        registers[:group_id].eq(self.id).and(
          registers[:type].eq("Register::Output").or(
            registers[:type].eq("Register::Virtual").and(registers[:mode].eq('out')))
        )
      )
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
      %w(localpool tribe)
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
      group_ids = Group::Base.all.readable_by_world.ids
      if user.nil?
        return group_ids
      else
        group_ids << Group::Base.where(readable: 'community').collect(&:id)
        group_ids << Group::Base.with_role(:manager, user).collect(&:id)
        group_ids << user.accessible_registers.collect(&:group).compact.collect(&:id)

        user.friends.each do |friend|
          if friend
            Group::Base.where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
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
    alias :score_interval :set_score_interval

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
      addresses_out = self.registers.outputs.collect(&:address).compact
      addresses_in = self.registers.inputs.collect(&:address).compact
      sum_distances = -1
      addresses_in.each do |address_in|
        addresses_out.each do |address_out|
          sum_distances += address_in.distance_to(address_out) if address_in.longitude && address_out.longitude
        end
      end
      closeness = -1
      if addresses_out.count * addresses_in.count != 0
        average_distance = sum_distances / (addresses_out.count * addresses_in.count)
        if average_distance < 0
          closeness = -1
        elsif average_distance < 5
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

    # only used in railsview controller
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

    def finalize_registers
      # TODO: check data source if other organization than discovergy
      if self.registers.size < 3
        return false
      end
      #TODO ideally the discovergy_data_source gets passed in from outside here
      data_source = Buzzn::Application.config.data_source_registry.get(:discovergy)
      brokers = data_source.create_virtual_meters_for_group(self)
      if brokers.any?
        return true
      end
      return false
    end

    # for railsview
    def class_name
      self.class.name.downcase.sub!("::", "_")
    end


    private

      def destroy_content
        self.registers.each do |register|
          register.group = nil
          register.save
        end
        GroupRegisterRequest.where(group: self).each{|request| request.destroy}
        self.root_comments.each{|comment| comment.destroy}
      end
  end
end
