# coding: utf-8
require 'file_size_validator'
class Device < ActiveRecord::Base
  include Filterable

  BIO_MASS = 'bio_mass'
  BIO_GAS = 'bio_gas'
  NATURAL_GAS = 'natural_gas' # erdgas
  FLUID_GAS = 'fluid_gas'
  FUEL_OIL = 'fuel_oil' # Heizöl
  WOOD = 'wood'
  VEG_OIL = 'veg_oil' # Pflenzenöl
  SUN = 'sun'
  WIND = 'wind'
  WATER = 'water'
  OTHER = 'other'

  class << self
    def all_primary_energies
      @primary_energy ||= [BIO_MASS, BIO_GAS, NATURAL_GAS, FLUID_GAS, FUEL_OIL,
                            WOOD, VEG_OIL, SUN, WIND, WATER, OTHER]
    end
  end

  belongs_to :register, class_name: Register::Base, foreign_key: :register_id

  mount_uploader :image, PictureUploader

  validates :mode, presence: true
  validates :manufacturer_name, presence: true, length: { in: 2..30 }
  validates :manufacturer_product_name, presence: true, length: { in: 2..30 }
  validates :watt_peak, numericality: { only_integer: true }, presence: true
  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }
  validates :primary_energy, inclusion: {in: self.all_primary_energies}, if: 'primary_energy.present?'

  def self.search_attributes
    [:manufacturer_name, :manufacturer_product_name, :mode, :category,
     :shop_link]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end


  def self.readables
    %w{
      me
      friends
      world
    }
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
    }
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
