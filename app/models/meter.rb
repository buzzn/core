class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Filterable

  has_ancestry
  validates :manufacturer_product_serialnumber, presence: true, uniqueness: true   #, unless: "self.virtual"
  mount_uploader :image, PictureUploader
  before_destroy :release_metering_points
  has_many :equipments
  has_many :metering_points
  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :readable_by, ->(user) do
    if user.nil?
      where('1=0')
    else
      # admin or manager query
      meter          = Meter.arel_table
      metering_point = MeteringPoint.arel_table
      users_roles    = Arel::Table.new(:users_roles)
      admin_or_manager = User.roles_query(user, manager: metering_point[:id], admin: nil)

      # with AR5 you can use left_outer_joins directly
      # `left_outer_joins(:metering_points)` instead of this mp_on and mp_join
      mp_on   = meter.create_on(meter[:id].eq(metering_point[:meter_id]))
      mp_join = meter.create_join(metering_point, mp_on,
                                  Arel::Nodes::OuterJoin)

      # need left outer join to get all meters without metering_point as well
      # sql fragment 'exists select 1 where .....'
      joins(mp_join).where(admin_or_manager.project(1).exists)
    end
  end

  def self.accessible_by_user(user, serialnumber)
    metering_point = MeteringPoint.arel_table
    manager = User.roles_query(user, manager: metering_point[:id])
    meters = joins(:metering_points).where(manager.project(1).exists)
    if serialnumber
      meters = meters.where(manufacturer_product_serialnumber: serialnumber)
    end
    meters
  end

  def name
    "#{manufacturer_name} #{manufacturer_product_serialnumber}"
  end


  def metering_points_modes_and_ids
    metering_point_mode_and_ids = {}
    self.metering_points.each do |metering_point|
      metering_point_mode_and_ids.merge!({"#{metering_point.mode}" => metering_point.id})
    end
    return metering_point_mode_and_ids
  end

  def self.manufacturer_names
    %w{
      easy_meter
      amperix
      ferraris
      other
    }.map(&:to_sym)
  end


  def self.pull_readings
    update_info = []
    Meter.where(init_reading: true, smart: true, online: true).each do |meter|
      meter.metering_points.each do |metering_point|
        mpoc  = metering_point.metering_point_operator_contract
        last  = Reading.last_by_metering_point_id(metering_point.id)[:timestamp]
        now   = Time.now.in_time_zone.utc
        range = (last.to_i .. now.to_i)
        if range.count < 1.hour
          Sidekiq::Client.push({
           'class' => GetReadingWorker,
           'queue' => :low,
           'args' => [
                      meter.metering_points_modes_and_ids,
                      meter.manufacturer_product_serialnumber,
                      mpoc.organization.slug,
                      mpoc.username,
                      mpoc.password,
                      last.to_i * 1000,
                      now.to_i * 1000
                     ]
          })
          update_info << "metering_point_id: #{metering_point.id} | from: #{Time.at(last)}, to: #{Time.at(now)}, #{range.count} seconds"
        else
          metering_point.meter.update_columns(online: false)
          #self.send_notification_meter_offline(meter)
        end
      end
    end
    return update_info
  end


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
    meter.metering_points.each do |metering_point|
      metering_point.managers.each do |user|
        user.send_notification("warning", I18n.t("metering_point_offline"), I18n.t("your_metering_point_is_offline_now", metering_point_name: metering_point.name))
        Notifier.send_email_notification_meter_offline(user, metering_point).deliver_now if user.profile.email_notification_meter_offline
      end
    end
  end

  def self.search_attributes
    [:manufacturer_name, :manufacturer_product_name]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

private

  def release_metering_points
    self.metering_points.each do |metering_point|
      metering_point.contracts.metering_point_operators.each do |contract|
        contract.destroy
      end
      metering_point.meter = nil
      metering_point.save
    end
  end



end
