class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  def slug_candidates
    [
      :username,
      [:first_name, :last_name]
    ]
  end

  mount_uploader :image, PictureUploader

  belongs_to :user

  #validates :username, allow_blank: true, uniqueness: true, length: { in: 4..30 }
  validates :first_name, presence: true, length: { in: 3..30 }
  validates :last_name,  presence: true, length: { in: 3..30 }
  validates_acceptance_of :terms, accept: true

  default_scope -> { order(:created_at => :desc) }


  def self.genders
    %w{
      male
      female
      intersex
    }
  end


  def name
    if self.username && self.username != ""
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
