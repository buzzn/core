require 'file_size_validator'

class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :user_name, use: [:slugged, :finders]


  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, presence: true, uniqueness: true, length: { in: 2..30 }

  validates_acceptance_of :terms, accept: true

  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }

  normalize_attributes :user_name, :first_name, :last_name

  delegate :friends, to: :user
  delegate :friendships, to: :user
  delegate :groups, to: :user

  def metering_points
    metering_points = []
    metering_points << self.user.metering_points # as member
    metering_points << MeteringPoint.editable_by_user(self.user) # as manager
    metering_points.flatten.uniq
  end

  def self.genders
    %w{
      male
      female
      intersex
    }.map(&:to_sym)
  end


  def name
    if first_name != nil && last_name != nil
      "#{first_name} #{last_name}"
    else
      user_name
    end
  end



end
