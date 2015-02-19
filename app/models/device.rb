class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :metering_point

  mount_uploader :image, PictureUploader

  validates :watt_peak, numericality: { only_integer: true }, presence: true
  validates :manufacturer_product_name, presence: true, length: { in: 2..30 }
  validates :manufacturer_name, allow_blank: true, length: { in: 2..30 }


  validates :mode, presence: true


  default_scope { order('created_at ASC') }

  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end

  def self.laws
    %w{
      eeg
      kwkg
    }.map(&:to_sym)
  end

  def self.modes
    %w{
      in
      out
    }.map(&:to_sym)
  end

  def self.primary_energies
    %w{
      gas
      oil
      lpg
      sun
      wind
      water
      biomass
    }.map(&:to_sym)
  end


  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def in_and_output?
    self.mode == 'in_out'
  end

  def editable_users
    User.with_role(:manager, self).to_a
  end


end
