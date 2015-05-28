class Dashboard < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :user

  has_many :dashboard_metering_points
  has_many :metering_points, :through => :dashboard_metering_points

end
