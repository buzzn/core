class User < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable,
         :confirmable, :invitable #, :omniauthable

  has_one :contracting_party

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile

  has_many :friendships
  has_many :friends, :through => :friendships, after_add: :create_complement_friendship

  has_many :metering_point_users
  has_many :metering_points, :through => :metering_point_users

  has_many :group_users
  has_many :groups, :through => :group_users



  def friend?(user)
    self.friendships.where(friend: user).empty? ? false : true
  end

  def received_friendship_requests
    FriendshipRequest.where(receiver: self)
  end

  def sent_friendship_requests
    FriendshipRequest.where(sender: self)
  end

  def sent_group_metering_point_requests
    GroupMeteringPointRequest.where(user: self)
  end

  def name
    if profile.persisted?
      profile.name
    else
      email
    end
  end

  def editable_locations
    Location.with_role(:manager, self).decorate
  end

  def editable_groups
    Group.with_role(:manager, self).decorate
  end

  def editable_devices
    Device.with_role(:manager, self).decorate
  end


private
  def create_complement_friendship(friend)
    friend.friends << self unless friend.friends.include?(self)
  end

end