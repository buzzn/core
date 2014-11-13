class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  def slug_candidates
    [
      :username,
      [:first_name, :last_name],
      self.user.email
    ]
  end

  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :username, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates_acceptance_of :terms, accept: true


  def self.genders
    %w{
      male
      female
      intersex
    }
  end


  def name
    if self.username
      "#{self.username}"
    else
      if self.first_name && self.last_name
        "#{self.first_name} #{self.last_name}"
      elsif self.user
        self.user.email
      else
        false
      end
    end
  end

end
