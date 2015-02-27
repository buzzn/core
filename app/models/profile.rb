class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :user_name, use: [:slugged, :finders]

  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, presence: true, uniqueness: true, length: { in: 3..30 }

  validates_acceptance_of :terms, accept: true



  def self.genders
    %w{
      male
      female
      intersex
    }.map(&:to_sym)
  end


  def name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      user_name
    end
  end


end
