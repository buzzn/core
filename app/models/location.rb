class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, UserPictureUploader

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :metering_points, -> { order("position DESC") }, dependent: :destroy
  accepts_nested_attributes_for :metering_points, reject_if: :all_blank, allow_destroy: true
end
