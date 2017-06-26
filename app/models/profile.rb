require 'file_size_validator'
class Profile < ActiveRecord::Base
  resourcify

  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, presence: true, uniqueness: true, length: { in: 2..63 }
  validates :first_name, presence: true, length: { in: 2..30 }
  validates :last_name, presence: true, length: { in: 2..30 }

  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }

  normalize_attributes :user_name, :first_name, :last_name

  after_destroy do
    user.roles.delete_all
    user.update(profile: nil)
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

  def self.search(search)
    if search
      where('first_name ILIKE ? or last_name ILIKE ? or user_name ILIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

end
