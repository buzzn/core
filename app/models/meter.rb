class Meter < ActiveRecord::Base
  include Authority::Abilities

  validates :manufacturer_product_serialnumber, :registers, presence: true

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, :reject_if => :all_blank, :allow_destroy => true

  has_many :equipments
  accepts_nested_attributes_for :equipments, :reject_if => :all_blank, :allow_destroy => true

  mount_uploader :image, PictureUploader

  after_save :validates_smartmeter_job


  def validates_smartmeter
    if metering_point
      if metering_point.metering_point_operator_contract
        @mpoc = metering_point.metering_point_operator_contract
        if @mpoc.organization.slug == 'discovergy' || @mpoc.organization.slug == 'buzzn-metering'
          request = Discovergy.new(@mpoc.username, @mpoc.password).raw(manufacturer_product_serialnumber)
          if request['status'] == 'ok'
            self.update_columns(smart: true)
            self.update_columns(online: request['result'].any?)
            self.delay.init_reading
          elsif request['status'] == "error"
            logger.error request
            self.update_columns(smart: false)
            self.update_columns(online: false)
          else
            logger.error request
          end
        else
          logger.warn "Meter:#{self.id} is not posible to validate. @metering_point:#{@metering_point}, @mpoc:#{metering_point.metering_point_operator_contract}"
          self.update_columns(smart: false)
          self.update_columns(online: false)
        end
      else
        logger.warn "Meter:#{self.id} has no metering_point_operator_contract"
      end
    else
      logger.warn "Meter:#{self.id} has no metering_point"
    end
  end



  def metering_point
    self.registers.collect(&:metering_point).first
  end

  def init_reading
    if self.registers.any? && self.smart && self.online
      if Reading.latest_by_register_id(self.registers.first.id)
        logger.warn "Meter:#{self.id} init reading already written"
      else
        @metering_point = metering_point
        @mpoc           = metering_point.metering_point_operator_contract
        if @metering_point && @mpoc
          @mpoc         = metering_point.metering_point_operator_contract
          init_reading  = true

          # nil means current time
          start_time    = nil
          end_time      = nil

          self.registers.each do |register|
            Sidekiq::Client.push({
             'class' => MeterReadingUpdateWorker,
             'queue' => :default,
             'args' => [
                        register.id,
                        self.manufacturer_product_serialnumber,
                        @mpoc.organization.slug,
                        @mpoc.username,
                        @mpoc.password,
                        start_time,
                        end_time,
                        init_reading
                       ]
            })
          end
        end
      end
    else
      logger.warn "Meter#{self.id}: is not posible to initialize. registers:#{self.registers.size}, smart:#{self.smart}, online:#{self.online}"
    end
  end


  def self.manufacturers
    %w{
      ferraris
      smart_meter
    }
  end


private

  def validates_smartmeter_job
    self.delay.validates_smartmeter
  end


end