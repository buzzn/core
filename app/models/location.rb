class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :users, -> { uniq }, :through => :metering_points
  has_many :devices, -> { uniq }, :through => :metering_points

  mount_uploader :image, PictureUploader

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :metering_points, -> { order("position DESC") }, dependent: :destroy
  accepts_nested_attributes_for :metering_points, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end
