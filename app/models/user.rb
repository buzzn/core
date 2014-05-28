class User < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable #,:confirmable, :omniauthable

  has_one :contracting_party, inverse_of: :user

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  has_many :user_metering_points
  has_many :metering_points, :through => :user_metering_points

  belongs_to :group

  def name
    if profile.persisted?
      profile.name
    else
      email
    end
  end

end