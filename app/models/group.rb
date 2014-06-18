class Group < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  include PublicActivity::Model
  tracked

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, uniqueness: true

  normalize_attribute :name, with: [:strip]

  has_one :area
  has_many :metering_points

  has_many :group_users
  has_many :users, :through => :group_users

end