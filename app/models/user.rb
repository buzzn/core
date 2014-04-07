class User < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, UserPictureUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, :lockable, :timeoutable #, :omniauthable

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  validates :first_name, presence: true
  validates :last_name, presence: true


  def name
    "#{self.first_name} #{self.last_name}"
  end

end
