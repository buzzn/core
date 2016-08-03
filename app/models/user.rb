class User < ActiveRecord::Base
  rolify
  include Authority::Abilities
  include Authority::UserAbilities
  include PublicActivity::Model
  include Filterable
  tracked except: [:create, :update, :destroy], owner: Proc.new{ |controller, model| controller && controller.current_user }

  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable,
         :confirmable, :invitable, :omniauthable#, :omniauth_providers => [:facebook]

  validates :legal_notes, acceptance: true

  acts_as_voter

  has_one :contracting_party
  has_one :dashboard
  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile
  has_many :friendships
  has_many :friends, :through => :friendships, after_add: :create_complement_friendship
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', dependent: :destroy, :foreign_key => :resource_owner_id
  has_many :notification_unsubscribers

  # TODO remove delegates
  delegate :slug, to: :profile
  delegate :name, to: :profile
  delegate :user_name, to: :profile
  delegate :first_name, to: :profile
  delegate :last_name, to: :profile
  delegate :about_me, to: :profile
  delegate :image, to: :profile

  before_destroy :delete_content

  after_create :create_dashboard
  after_create :create_rails_view_access_token

  after_invitation_accepted :invoke_invitation_accepted_activity

  scope :exclude_user, lambda {|user|
    where('user_id NOT IN (?)', [user.id])
  }

  scope :registered, -> { where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NOT NULL OR invitation_sent_at IS NULL') }
  scope :unregistered, -> { where('invitation_sent_at IS NOT NULL AND invitation_accepted_at IS NULL') }

  def self.search_attributes
    [:email, profile: [:first_name, :last_name]]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

  def self.dummy
    self.where(email: 'sys@buzzn.net').first
  end

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
    GroupMeteringPointRequest.where(user: self).requests
  end

  def received_group_metering_point_requests
    GroupMeteringPointRequest.where(user: self).invitations
  end

  def received_metering_point_user_requests
    MeteringPointUserRequest.where(user: self).invitations
  end

  def old_badge_notifications
    BadgeNotification.where(user: self).read
  end

  def new_badge_notifications
    BadgeNotification.where(user: self).unread
  end




  def editable_metering_points
    MeteringPoint.editable_by_user(self).collect(&:decorate)
  end

  def editable_meters
    Meter.editable_by_user(self)
  end

  def editable_groups
    Group.editable_by_user(self).collect(&:decorate)
  end

  def editable_devices
    Device.editable_by_user(self).collect(&:decorate)
  end

  def editable_addresses
    self.editable_metering_points.collect(&:address).compact.uniq{|address| address.longitude && address.latitude}
  end

  def non_private_editable_metering_points
    MeteringPoint.editable_by_user(self).non_privates.collect(&:decorate)
  end

  def metering_points_as_member
    MeteringPoint.with_role(:member, self).collect(&:decorate)
  end

  def accessible_metering_points
    MeteringPoint.accessible_by_user(self).uniq.collect(&:decorate)
  end

  def self.unsubscribed_from_notification(key, resource)
    result = []
    result << NotificationUnsubscriber.by_resource(resource).by_key(key).collect(&:user)
    if resource.is_a?(Group) || resource.is_a?(MeteringPoint)
      result << NotificationUnsubscriber.within_users(resource.involved).by_key(key).collect(&:user)
    end
    return result.flatten
  end

  def wants_to_get_notified_by_email?(key, resource)
    NotificationUnsubscriber.by_user(self).by_resource(resource).by_key(key).empty?
  end

  def accessible_groups_relation
    group = Group.arel_table

    mp = MeteringPoint.arel_table
    mp_on = mp.create_on(mp['group_id'].eq(group['id']))
    mp_join = mp.create_join(mp, mp_on, Arel::Nodes::OuterJoin)

    role = Role.arel_table
    role_on = role.create_on(role['resource_id'].eq(mp['id']).and(role['resource_type'].eq(MeteringPoint.to_s)).and(role['name'].in([:manager, :member])).or(role['resource_id'].eq(group['id']).and(role['resource_type'].eq(Group.to_s)).and(role['name'].eq(:manager))))
    role_join = role.create_join(role, role_on)
    
    users_roles = Arel::Table.new(:users_roles)
    users_roles_on = users_roles.create_on(users_roles[:role_id].eq(role[:id]))
    users_roles_join = users_roles.create_join(users_roles, users_roles_on)

    Group.distinct.joins(mp_join, role_join, users_roles_join).where('users_roles.user_id': self)
  end

  def accessible_groups
    result = []
    result << Group.editable_by_user(self).collect(&:decorate)
    result << self.accessible_metering_points.collect(&:group).compact.collect(&:decorate)
    return result.flatten.uniq
  end

  def usable_metering_points
    result = self.editable_metering_points
    self.friends.each do |friend|
      result << friend.non_private_editable_metering_points
    end
    editable_metering_points_without_meter_not_virtual
    return result.flatten.uniq
  end

  def invitable_users(metering_point)
    result = self.friends.collect(&:profile).compact.collect(&:user)
    not_invitable = []

    metering_point.users.each do |user|
      user.profile.nil? ? nil : not_invitable << user
    end
    return result - not_invitable
  end

  def accessible_metering_points_by_address
    result = []
    without_address = []
    all_metering_points = MeteringPoint.accessible_by_user(self)
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

  def editable_metering_points_without_meter_not_virtual
    MeteringPoint.editable_by_user_without_meter_not_virtual(self)
  end

  #defined types: primary, info, success, warning, danger, mint, purple, pink, dark
  def send_notification(type, header, message, duration, url)
    if url
      ActionView::Base.send(:include, Rails.application.routes.url_helpers)
      @message = ActionController::Base.helpers.link_to(message, url)
      @header = ActionController::Base.helpers.link_to(header, url)
    else
      @message = message
      @header = header
    end
    Sidekiq::Client.push({
     'class' => PushNotificationWorker,
     'queue' => :default,
     'args' => [
                self.id,
                type,
                @header,
                @message,
                duration
               ]
    })
  end

  def send_email(header, message)
    Notifier.send_email_to_user_variable_content(self, header, message).deliver_now
  end





  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def self.from_omniauth(auth)
    omniauth_users = where(provider: auth.provider, uid: auth.uid)
    if omniauth_users.any?
      return omniauth_users.first
    else
      # https://github.com/mkdynamic/omniauth-facebook#auth-hash

      profile                   = Profile.new
      profile.user_name         = "#{auth.info.first_name} #{auth.info.last_name}"
      profile.first_name        = auth.info.first_name
      profile.last_name         = auth.info.last_name
      profile.remote_image_url  = auth.info.image

      user            = User.new()
      user.uid        = auth.uid
      user.provider   = auth.provider
      user.email      = auth.info.email
      user.password   = Devise.friendly_token[0,20]
      user.profile    = profile

      user.save!
      user.confirm

      return user
    end
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end






private
  def create_complement_friendship(friend)
    friend.friends << self unless friend.friends.include?(self)
  end

  def create_dashboard
    self.dashboard = Dashboard.create(user_id: self.id)
  end

  def create_rails_view_access_token
    application = Doorkeeper::Application.where(name: 'Buzzn RailsView')
    if application.any?
      Doorkeeper::AccessToken.create(application_id: application.first.id, resource_owner_id: self.id, scopes: 'public full' )
    end
  end

  def invoke_invitation_accepted_activity
    self.create_activity(key: 'user.accept_platform_invitation', owner: self, recipient: self.invited_by)
    self.update_attributes(:data_protection_guidelines => I18n.t('data_protection_guidelines_html'), :terms_of_use => I18n.t('terms_of_use_html'))
  end

  def delete_content
    self.editable_groups.each do |group|
      if (group.managers.count == 1 && !group.in_metering_points.collect{|metering_point| self.can_update?(metering_point)}.include?(false))
        group.destroy
      end
    end
    self.editable_metering_points.each do |metering_point|
      if metering_point.managers.count == 1 && (metering_point.users.count <= 1 && (metering_point.users.include?(self) || metering_point.users.empty?))
        metering_point.destroy
      end
    end
    MeteringPointUserRequest.where(user: self).each{|request| request.destroy}
    FriendshipRequest.where(sender: self).each{|request| request.destroy}
    FriendshipRequest.where(receiver: self).each{|request| request.destroy}
    dummy_user = User.dummy
    Comment.where(user: self).each do |comment|
      comment.user_id = dummy_user.id
      comment.save
    end
    PublicActivity::Activity.where(owner: self).each do |activity|
      activity.owner_id = dummy_user.id
      activity.save
    end
    PublicActivity::Activity.where(recipient: self).each do |activity|
      activity.recipient_id = dummy_user.id
      activity.save
    end


    self.roles.each{|role| role.destroy}
  end

end
