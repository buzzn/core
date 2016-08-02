require 'file_size_validator'

class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :user_name, use: [:slugged, :history, :finders]


  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, uniqueness: true, length: { in: 2..63 }
  validates :first_name, presence: true, length: { in: 2..30 }
  validates :last_name, presence: true, length: { in: 2..30 }

  #validates :terms, acceptance: true

  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }

  normalize_attributes :user_name, :first_name, :last_name

  delegate :friends, to: :user
  delegate :friendships, to: :user
  delegate :groups, to: :user

  def generate_username
    if first_name && last_name && user_name.nil?
      new_user_name = first_name.downcase + last_name.downcase
      #profiles = Profile.where(user_name: new_user_name)
      profiles = Profile.where('user_name ~* ?', new_user_name + '(?:\d+$|)').order(:user_name)
      if profiles.any?
        max = 0
        profiles.each do |profile|
          number = profile.user_name[/\d+$/].to_i
          number > max ? max = number : nil
        end
        self.user_name = new_user_name + (max+1).to_s
      else
        self.user_name = new_user_name
      end
    end
  end

  def should_generate_new_friendly_id?
    self.generate_username
    slug.blank? || user_name_changed?
  end

  # def metering_points
  #   metering_points = []
  #   metering_points << self.user.metering_points # as member
  #   metering_points << MeteringPoint.editable_by_user(self.user) # as manager
  #   metering_points.compact.flatten.uniq
  # end

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

  def self.search(search)
    if search
      where('first_name ILIKE ? or last_name ILIKE ? or user_name ILIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_world?
    self.readable == 'world'
  end

  def readable_by_members?
    self.readable == 'members'
  end

  def readable_by_community?
    self.readable == 'community'
  end


end
