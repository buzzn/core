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
    @metering_point = metering_point
    if @metering_point && @metering_point.metering_point_operator_contracts.running.any?
      @mpoc = @metering_point.metering_point_operator_contracts.running.first
      if @mpoc.organization.slug == 'discovergy' || @mpoc.organization.slug == 'buzzn-metering'
        api_call = Discovergy.new(@mpoc.username, @mpoc.password).raw(manufacturer_product_serialnumber)
        if api_call['status'] == 'ok'
          self.update_columns(smart: true)
          self.update_columns(online: api_call['result'].any?)
          init_reading
        else
          self.update_columns(smart: false)
          self.update_columns(online: false)
          @mpoc.validates_credentials
        end
      end
    else
      self.update_columns(smart: false)
      self.update_columns(online: false)
    end
  end

  def metering_point
    self.registers.collect(&:metering_point).first
  end

  def init_reading
    if self.registers.any?
      if Reading.latest_by_register_id(self.registers.first.id)
        logger.warn "Meter:#{self.id} init reading already written"
      else
        @metering_point = metering_point
        if @metering_point && @metering_point.metering_point_operator_contracts.running.any?
          mpoc          = metering_point.metering_point_operator_contracts.running.first
          init_reading  = true

          # nil = current time
          start_time    = nil
          end_time      = nil

          self.registers.each do |register|
            
            Sidekiq::Client.push({
             'class' => MeterReadingUpdateWorker,
             'queue' => :high,
             'args' => [ 
                        register.id,
                        self.manufacturer_product_serialnumber,
                        mpoc.organization.slug,
                        mpoc.username,
                        mpoc.password,
                        start_time,
                        end_time,
                        init_reading
                       ]
            })

          end
        end
      end
    else
      logger.warn "Meter#{self.id}: has no registers"
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