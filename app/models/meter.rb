class Meter < ActiveRecord::Base

  include Authority::Abilities

  extend FriendlyId
  friendly_id :slug_name, use: [:slugged, :finders]

  has_ancestry

  validates :manufacturer_product_serialnumber, presence: true    #, unless: "self.virtual"

  mount_uploader :image, PictureUploader

  after_save :validates_smartmeter_job

  default_scope { order('created_at ASC') }


  has_many :equipments

  has_many :metering_points




  def slug_name
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
      ferraris
      landis_gyr
      goerlitz
      elster
      bauer
      nzr
      emh
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







private

  def validates_smartmeter_job
    Sidekiq::Client.push({
     'class' => MeterInitWorker,
     'queue' => :low,
     'args' => [ self.id ]
    })
  end

end