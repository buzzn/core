class Device < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :metering_point

  mount_uploader :image, PictureUploader

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


  def out?
    self.mode == 'out'
  end

  def in?
    self.mode == 'in'
  end

  def in_out?
    self.mode == 'in_out'
  end


end
