class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :metering_point

  has_many :assets, as: :assetable, dependent: :destroy


  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end

  def self.generator_types
    %w{
      pv
      chp
      wind
    }
  end

  def self.laws
    %w{
      eeg
      kwkg
    }
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
