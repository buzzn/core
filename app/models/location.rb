class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :metering_points, -> { order("position DESC") }
  accepts_nested_attributes_for :metering_points, reject_if: :all_blank, allow_destroy: true

end
