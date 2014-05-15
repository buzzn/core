class Profile < ActiveRecord::Base
  include Authority::UserAbilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, UserPictureUploader

  belongs_to :user


  validates :first_name, presence: true
  validates :last_name, presence: true


  def name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.email
    end
  end

end
