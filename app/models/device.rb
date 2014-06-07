class Device < ActiveRecord::Base
  include Authority::Abilities

  has_and_belongs_to_many :metering_points

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


  def up?
    self.mode == 'up'
  end

  def down?
    self.mode == 'down'
  end

  def up_down?
    self.mode == 'up_down'
  end


end
