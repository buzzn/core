module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
    resourcify
    include Authority::Abilities
    include Filterable
    include Buzzn::GuardedCrud

    # VoltageLevel
    LOW_LEVEL = 'low_level'
    MID_LEVEL = 'mid_level'
    HIGH_LEVEL = 'high_level'
    HIGHEST_LEVEL = 'highest_level'

    # CycleInterval
    MONTHLY = 'monthly'
    YEARLY = 'yearly'
    QUARTERLY = 'quarterly'
    HALF_YEARLY = 'half_yearly'

    # MeteringType
    ANALOG_HOUSEHOLD_METER = 'analog_household_meter'
    SMART_METER = 'smart_meter'
    LOAD_METER = 'load_meter' # Lastgangzähler
    ANALOG_AC_METER = 'analog_ac_meter' # Wechselstromzähler
    DIGITAL_HOUSEHOLD_METER = 'digital_household_meter'
    MAXIMUM_METER = 'maximum_meter'
    INDIVIDUAL_ADJUSTMENT = 'individual_adjustment'

    # MeterSize
    EDL40 = 'edl40'
    EDL21 = 'edl21'
    OTHER_EHZ = 'other_ehz'

    # Tariff
    ONE_TARIFF = 'one_tariff'
    TWO_TARIFFS = 'two_tariffs'
    MULTIPLE_TARIFFS = 'multiple_tariffs'

    # DataLogging
    REMOTE = 'remote'
    MANUAL = 'manual'

    # MountingMethod
    PLUG_TECHNIQUE = 'plug_technique'
    THREE_POINT_HANGING = 'three_point_hanging'
    CAP_RAIL = 'cap_rail' # Hutschiene

    # ownership
    BUZZN_SYSTEMS = 'buzzn_systems'
    FOREIGN_OWNERSHIP = 'foreign_ownership'
    CUSTOMER = 'customer'
    LEASED = 'leased'
    BOUGHT = 'bought'

    # direction
    ONE_WAY_METER = 'one_way_meter'
    TWO_WAY_METER = 'two_way_meter'


    class << self
      def all_voltage_levels
        @voltage_level ||= [LOW_LEVEL, MID_LEVEL, HIGH_LEVEL, HIGHEST_LEVEL]
      end

      def all_cycle_intervals
        @cycle_interval ||= [MONTHLY, YEARLY, QUARTERLY, HALF_YEARLY]
      end

      def all_metering_types
        @metering_type ||= [ANALOG_HOUSEHOLD_METER, SMART_METER, LOAD_METER, ANALOG_AC_METER,
                            DIGITAL_HOUSEHOLD_METER, MAXIMUM_METER, INDIVIDUAL_ADJUSTMENT]
      end

      def all_meter_sizes
        @meter_size ||= [EDL40, EDL21, OTHER_EHZ]
      end

      def all_tariffs
        @tariff ||= [ONE_TARIFF, TWO_TARIFFS, MULTIPLE_TARIFFS]
      end

      def all_data_loggings
        @data_logging ||= [REMOTE, MANUAL]
      end

      def all_mounting_methods
        @mounting_method ||= [PLUG_TECHNIQUE, THREE_POINT_HANGING, CAP_RAIL]
      end

      def all_ownerships
        @ownership ||= [BUZZN_SYSTEMS, FOREIGN_OWNERSHIP, CUSTOMER, LEASED, BOUGHT]
      end
    end

    has_one :broker, as: :resource, dependent: :destroy, foreign_key: :resource_id, class_name: 'Broker::Base'
    validates_associated :broker

    has_one :main_equipment, class_name: Meter::Equipment, foreign_key: 'meter_id'
    has_one :secondary_equipment, class_name: Meter::Equipment, foreign_key: 'meter_id'

    # TODO ????, rename it to :direction
    validates :mode, presence: false
    validates :measurement_capture, presence: false
    validates :build_year, presence: false
    validates :calibrated_till, presence: false
    # TODO makes no sense for virtual meters
    validates :smart, presence: false
    validates :init_first_reading, presence: false
    validates :init_reading, presence: false
    validates :voltage_level, inclusion: {in: all_voltage_levels}, if: 'voltage_level.present?'
    validates :cycle_interval, inclusion: {in: all_cycle_intervals}, if: 'cycle_interval.present?'
    validates :metering_type, inclusion: {in: all_metering_types}, if: 'metering_type.present?'
    validates :meter_size, inclusion: {in: all_meter_sizes}, if: 'meter_size.present?'
    validates :tariff, inclusion: {in: all_tariffs}, if: 'tariff.present?'
    validates :data_logging, inclusion: {in: all_data_loggings}, if: 'data_logging.present?'
    validates :mounting_method, inclusion: {in: all_mounting_methods}, if: 'mounting_method.present?'
    validates :ownership, inclusion: {in: all_ownerships}, if: 'ownership.present?'

    validate :validate_invariants

    after_create :create_main_equipment

    def validate_invariants
    end

    before_destroy do
      Meter::Equipment.where(meter_id: self.id).delete_all
    end

    # it differs from updatable_by as they do not have admins
    scope :editable_by_user, lambda {|user|
      readable_by(user, false)
    }

    # this has no admins !
    def self.accessible_by_user(user)
      readable_by(user, false)
    end

    scope :readable_by, ->(user, admin = true) do
      if user.nil?
        where('1=0')
      else
        # admin or manager query
        meter            = Meter::Base.arel_table
        register         = Register::Base.arel_table
        users_roles      = Arel::Table.new(:users_roles)
        roles = { manager: register[:id] }
        roles[:admin] = nil if admin
        admin_or_manager = User.roles_query(user, roles)

        # with AR5 you can use left_outer_joins directly
        # `left_outer_joins(:registers)` instead of this register_on and register_join
        register_on   = meter.create_on(meter[:id].eq(register[:meter_id]))
        register_join = meter.create_join(register, register_on, Arel::Nodes::OuterJoin)

        # need left outer join to get all meters without register as well
        # sql fragment 'exists select 1 where .....'
        joins(register_join).where(admin_or_manager.project(1).exists).distinct
      end
    end

    def name
      "#{manufacturer_name} #{manufacturer_product_serialnumber}"
    end

    def direction
      if registers.size == 1
        ONE_WAY_METER
      else
        TWO_WAY_METER
      end
    end

    # TODO seems to be not used
    def self.send_notification_meter_offline(meter)
      meter.registers.each do |register|
        register.managers.each do |user|
          user.send_notification("warning", I18n.t("register_offline"), I18n.t("your_register_is_offline_now", register_name: register.name))
          Notifier.send_email_notification_meter_offline(user, register).deliver_now if user.profile.email_notification_meter_offline
        end
      end
    end

    def self.search_attributes
      [:manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

    # for railsview
    def class_name
      self.class.name.downcase.sub!("::", "_")
    end

    def create_main_equipment
      if main_equipment.nil?
        Meter::Equipment.create!(converter_constant: 1, meter: self, ownership: Meter::Equipment::BUZZN_SYSTEMS)
      end
    end
  end
end
