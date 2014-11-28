class Meter < ActiveRecord::Base
  include Authority::Abilities

  validates :manufacturer_product_serialnumber, :registers, presence: true   #, unless: "self.virtual"

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, :reject_if => :all_blank, :allow_destroy => true

  has_many :virtual_registers, dependent: :destroy
  accepts_nested_attributes_for :virtual_registers, :reject_if => :all_blank, :allow_destroy => true

  has_many :equipments
  accepts_nested_attributes_for :equipments, :reject_if => :all_blank, :allow_destroy => true

  mount_uploader :image, PictureUploader

  after_save :validates_smartmeter_job


  def metering_point
    self.registers.collect(&:metering_point).first
  end

  def self.virtual
    self.registers.collect(&:metering_point).first.virtual
  end

  def registers_modes_and_ids
    register_mode_and_ids = {}
    self.registers.each do |register|
      register_mode_and_ids.merge!({"#{register.mode}" => register.id})
    end
    return register_mode_and_ids
  end

  def self.manufacturers
    %w{
      ferraris
      smart_meter
    }
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