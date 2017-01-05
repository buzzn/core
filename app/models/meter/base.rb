module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
    resourcify
    include Authority::Abilities
    include Filterable
    include Buzzn::GuardedCrud

    # TODO goes away !
    # what is this needed for the tree structure ?
    has_ancestry

    has_one :broker, as: :resource, :dependent => :destroy
    validates_associated :broker

    # free text field
    validates :owner, presence: false
    # TODO free text or enum ????
    validates :metering_type, presence: false
    validates :meter_size, presence: false, numericality: { only_integer: true }, allow_nil: true
    # yearly, monthly, etc
    validates :rate, presence: false
    # TODO ????
    validates :mode, presence: false
    validates :measurement_capture, presence: false
    validates :mounting_method, presence: false
    validates :build_year, presence: false
    validates :calibrated_till, presence: false

    # TODO makes no sense for virtual meters
    validates :smart, presence: false
    # TODO makes no sense for virtual meters
    validates :online, presence: false
    validates :init_first_reading, presence: false
    validates :init_reading, presence: false

    validate :validate_invariants

    def validate_invariants
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
        joins(register_join).where(admin_or_manager.project(1).exists)
      end
    end

    def name
      "#{manufacturer_name} #{manufacturer_product_serialnumber}"
    end

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
  end
end
