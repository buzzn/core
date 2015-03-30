class Dashboard < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :metering_points
end
