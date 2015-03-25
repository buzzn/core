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

  delegate :name, to: :profile

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



  def editable_metering_points
    MeteringPoint.editable_by_user(self).decorate
  end

  def editable_groups
    Group.editable_by_user(self).decorate
  end

  def editable_devices
    Device.editable_by_user(self).decorate
  end

  def usable_metering_points
    result = self.editable_metering_points
    self.friends.each do |friend|
      result << friend.editable_metering_points
    end
    return result.flatten
  end





private
  def create_complement_friendship(friend)
    friend.friends << self unless friend.friends.include?(self)
  end

end