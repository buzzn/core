require 'file_size_validator'

class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  #tracked recipient: Proc.new{ |controller, model| controller && model }

  belongs_to :metering_point

  mount_uploader :image, PictureUploader

  validates :mode, presence: true
  validates :manufacturer_name, presence: true, length: { in: 2..30 }
  validates :manufacturer_product_name, presence: true, length: { in: 2..30 }
  validates :watt_peak, numericality: { only_integer: true }, presence: true
  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }


  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }


  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end


  def readables
    %w{
      me
      friends
      world
    }.map(&:to_sym)
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
