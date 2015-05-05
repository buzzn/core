class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :user_name, use: [:slugged, :finders]

  def slug_candidates
    [
      :slug_name,
      :user_name
    ]
  end

  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, presence: true, uniqueness: true, length: { in: 2..30 }

  validates_acceptance_of :terms, accept: true

  normalize_attributes :user_name, :first_name, :last_name

  def metering_points
    metering_point_ids = []
    metering_point_ids << self.user.metering_points.collect(&:id) # as member
    metering_point_ids << MeteringPoint.editable_by_user(self.user).collect(&:id) # as manager
    MeteringPoint.where(id: metering_point_ids)
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

  private

    def slug_name
      SecureRandom.uuid
    end


end
