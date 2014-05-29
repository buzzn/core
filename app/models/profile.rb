class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, UserPictureUploader

  belongs_to :user


  validates :first_name, presence: true
  validates :last_name, presence: true


  def self.genders
    %w{
      male
      female
      intersex
    }
  end


  def name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.email
    end
  end

end
