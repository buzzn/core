class Device < ActiveRecord::Base
  include Authority::Abilities

  has_and_belongs_to_many :metering_points

  def self.generator_types
    %w{ pv chp wind }
  end

end
