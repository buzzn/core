require 'buzzn/guarded_crud'
class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Filterable
  include Buzzn::GuardedCrud

  has_ancestry
  validates :manufacturer_product_serialnumber, presence: true, uniqueness: true   #, unless: "self.virtual"
  mount_uploader :image, PictureUploader
  has_many :equipments

  has_one :register, class_name: 'Register::Base', dependent: :destroy

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :readable_by, ->(user) do
    if user.nil?
      where('1=0')
    else
      # admin or manager query
      meter            = Meter.arel_table
      register         = Register::Base.arel_table
      users_roles      = Arel::Table.new(:users_roles)
      admin_or_manager = User.roles_query(user, manager: register[:id], admin: nil)

      # with AR5 you can use left_outer_joins directly
      # `left_outer_joins(:registers)` instead of this register_on and register_join
      register_on   = meter.create_on(meter[:id].eq(register[:meter_id]))
      register_join = meter.create_join(register, register_on, Arel::Nodes::OuterJoin)

      # need left outer join to get all meters without register as well
      # sql fragment 'exists select 1 where .....'
      joins(register_join).where(admin_or_manager.project(1).exists)
    end
  end

  def self.accessible_by_user(user)
    register = Register::Base.arel_table
    manager = User.roles_query(user, manager: register[:id])
    meters = joins(:registers).where(manager.project(1).exists)
    meters
  end

  def name
    "#{manufacturer_name} #{manufacturer_product_serialnumber}"
  end


  def registers_modes_and_ids
    register_mode_and_ids = {}
    self.registers.each do |register|
      register_mode_and_ids.merge!({"#{register.mode}" => register.id})
    end
    return register_mode_and_ids
  end

  def self.manufacturer_names
    %w{
      easy_meter
      amperix
      ferraris
      other
    }.map(&:to_sym)
  end

  # TODO delete this
  def self.pull_readings
    update_info = []
    Meter.where(init_reading: true, smart: true, online: true).each do |meter|
      meter.registers.each do |register|
        mpoc  = register.metering_point_operator_contract
        last  = Reading.last_by_register_id(register.id)[:timestamp]
        now   = Time.current.utc
        range = (last.to_i .. now.to_i)
        if range.count < 1.hour
          Sidekiq::Client.push({
           'class' => GetReadingWorker,
           'queue' => :low,
           'args' => [
                      meter.registers_modes_and_ids,
                      meter.manufacturer_product_serialnumber,
                      mpoc.organization.slug,
                      mpoc.username,
                      mpoc.password,
                      last.to_i * 1000,
                      now.to_i * 1000
                     ]
          })
          update_info << "register_id: #{register.id} | from: #{Time.at(last)}, to: #{Time.at(now)}, #{range.count} seconds"
        else
          register.meter.update_columns(online: false)
          #self.send_notification_meter_offline(meter)
        end
      end
    end
    return update_info
  end

  # TODO delete this
  def self.reactivate
    Meter.where(init_reading: true, smart: true, online: false).select(:id).each do |meter|
      Sidekiq::Client.push({
       'class' => MeterReactivateWorker,
       'queue' => :low,
       'args' => [ meter.id ]
      })
    end
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



end
