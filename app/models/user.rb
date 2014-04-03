class User < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :image, UserPictureUploader

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :bank_accounts, dependent: :destroy 
  accepts_nested_attributes_for :bank_accounts, reject_if: :all_blank, allow_destroy: true

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, :lockable, :timeoutable #, :omniauthable


  def name
    "#{self.first_name} #{self.last_name}"
  end

end
