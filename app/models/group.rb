class Group < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, uniqueness: true

end