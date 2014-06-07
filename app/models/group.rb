class Group < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, uniqueness: true

  normalize_attribute :name, with: [:strip]

  has_one :area
  has_many :metering_points
end