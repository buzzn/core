require 'buzzn/score_calculator'

module Group
  class Base < ActiveRecord::Base
    self.table_name = :groups
    resourcify
    acts_as_commentable
    include Filterable

    HYBRID = 'hybrid'
    CHP = 'chp'
    PV = 'pv'

    before_save do
      self.slug = Buzzn::Slug.new(self.name)
    end

    before_destroy :destroy_content

    def meters
      Meter::Base.where(
        Register::Base.where('registers.group_id = ? and registers.meter_id = meters.id', self)
          .select(1)
          .exists
        )
    end

    validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

    mount_uploader :logo, PictureUploader
    #mount_uploader :image, PictureUploader

    has_many :registers, class_name: Register::Base, foreign_key: :group_id

    has_many :brokers, class_name: Broker::Base, as: :resource, :dependent => :destroy

    #has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users
    def managers
      User.users_of(self, :manager)
    end

    has_many :scores, as: :scoreable

    # validates :registers, presence: true

    normalize_attributes :description, :website

    scope :restricted, ->(uuids) { where(id: uuids) }


    def self.search_attributes
      [:name, :description]
    end

    def self.filter(search)
      do_filter(search, *search_attributes)
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



    def energy_generator_type
      all_labels = output_registers.collect(&:label).uniq
      if all_labels.include?(Register::Base::PRODUCTION_CHP) && all_labels.include?(Register::Base::PRODUCTION_PV)
        return HYBRID
      elsif all_labels.include?(Register::Base::PRODUCTION_CHP)
        return CHP
      elsif all_labels.include?(Register::Base::PRODUCTION_PV)
        return PV
      end
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
