class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :private_grid

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :metering_points
  accepts_nested_attributes_for :metering_points, reject_if: :all_blank, allow_destroy: true

end
