class User < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable,
         :confirmable, :invitable #, :omniauthable

  has_one :contracting_party

  has_one :dashboard

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile

  has_many :friendships
  has_many :friends, :through => :friendships, after_add: :create_complement_friendship

  has_many :metering_point_users
  has_many :metering_points, :through => :metering_point_users

  has_many :group_users
  has_many :groups, :through => :group_users

  delegate :name, to: :profile

  after_create :create_dashboard

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
    MeteringPoint.editable_by_user(self).collect(&:decorate)
  end

  def editable_groups
    Group.editable_by_user(self).collect(&:decorate)
  end

  def editable_devices
    Device.editable_by_user(self).collect(&:decorate)
  end

  def usable_metering_points
    result = self.editable_metering_points
    self.friends.each do |friend|
      result << friend.editable_metering_points
    end
    return result.flatten
  end

  def editable_metering_points_by_address
    result = []
    without_address = []
    all_metering_points =  MeteringPoint.editable_by_user(self)
    all_addresses = all_metering_points.collect(&:address).compact.uniq{|address| address.longitude && address.latitude}
    result << {:address => nil, :metering_points => all_metering_points} if all_addresses.empty?

    all_addresses.each do |address|
      metering_points_for_one_address = []
      all_metering_points.each do |metering_point|
        metering_point_address = metering_point.address
        if metering_point_address == nil
          if !without_address.include?(metering_point)
            without_address << metering_point
          end
          next
        elsif metering_point_address.longitude == address.longitude && metering_point_address.latitude == address.latitude
          metering_points_for_one_address << metering_point
        end
      end
      result << {:address => address, :metering_points => metering_points_for_one_address}
    end
    result << {:address => nil, :metering_points => without_address} if without_address.any?
    #coordinates = all_addresses.compact.collect{|address| [address.longitude, address.latitude]}.uniq
    #coordinates.each do |coordinate|
    #  addresses = Address.where(longitude: coordinate[0]).where(latitude: coordinate[1])
    #  result << {:address => addresses.first, :metering_points => addresses.collect(&:metering_point)}
    #end
    #without_address = all_metering_points.collect{|metering_point| metering_point if metering_point.address.nil?}.compact
    #result << {:address => nil, :metering_points => without_address} if without_address.any?
    return result
  end





private
  def create_complement_friendship(friend)
    friend.friends << self unless friend.friends.include?(self)
  end

  def create_dashboard
    self.dashboard = Dashboard.create(user_id: self.id)
  end

end