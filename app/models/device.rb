class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]


  belongs_to :metering_point

  mount_uploader :image, PictureUploader

  validates :mode, presence: true
  validates :manufacturer_name, presence: true, length: { in: 2..30 }
  validates :manufacturer_product_name, presence: true, length: { in: 2..30 }
  validates :watt_peak, numericality: { only_integer: true }, presence: true


  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }


  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end


  def secret_levels
    %w{
      secret
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
