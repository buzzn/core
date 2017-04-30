class User < ContractingParty
  rolify
  include Authority::Abilities
  include Authority::UserAbilities
  include PublicActivity::Model
  include Filterable
  include Buzzn::GuardedCrud
  # TODO remove this tracker and make it explicit. it already excludes all
  # three major actions
  tracked except: [:create, :update, :destroy], owner: Proc.new{ |controller, model| controller && controller.current_user }

  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable,
         :confirmable, :invitable, :omniauthable#, :omniauth_providers => [:facebook]

  validates :legal_notes, acceptance: true

  acts_as_voter

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

  validate :nil_profile
  def nil_profile
    if profile.nil? && !roles.empty?
      errors['roles'] = 'without profile the user can not have roles'
    end
  end

  def self.count_admins(user)
    count_roles(user, admin: nil)
  end

  def self.users_of(parent, *role_names)
    roles          = Role.arel_table
    users_roles    = Role.users_roles_arel_table

    map = {}
    role_names.each do |role|
      map[role] = parent
    end

    # sql fragment 'exists select 1 where .....'
    where(roles_query(nil, map).project(1).exists.to_sql)
  end

  def self.roles_query(user, role_map)
    roles          = Role.arel_table
    users_roles    = Role.users_roles_arel_table

    roles_constraint = nil
    role_map.each do |role, resources|
      resources = [resources] unless resources.is_a? Array
      resources.each do |resource|
        if roles_constraint
          roles_constraint = roles_constraint.or(roles[:name].eq(role)
                               .and(roles[:resource_id].eq(resource)))
        else
          roles_constraint = roles[:name].eq(role)
                             .and(roles[:resource_id].eq(resource))
        end
      end
    end
    user_id = if user
                if user.is_a? User
                  user.id
                else
                  user
                end
              else
                users = User.arel_table
                users[:id]
              end
    users_roles.join(roles)
      .on(roles[:id].eq(users_roles[:role_id])
           .and(roles_constraint))
      .where(users_roles[:user_id].eq(user_id))
  end

  def self.count_roles(user, role_map)
    users_roles    = Role.users_roles_arel_table
    roles_query(user, role_map).project(users_roles[:user_id].count)
  end

  def self.admin?(user)
    !!user && ActiveRecord::Base.connection.exec_query(count_admins(user).to_sql).first['count'].to_i > 0
  end

  def self.any_role?(user, roles_map)
    !!user && ActiveRecord::Base.connection.exec_query(count_roles(user, roles_map).to_sql).first['count'].to_i > 0
  end

  scope :readable_by, -> (user) do
    if User.admin?(user)
      User.all
    else
      users               = User.arel_table
      profiles            = Profile.arel_table
      users_profiles_on   = users.create_on(users[:id].eq(profiles[:user_id]))
      users_profiles_join = users.create_join(profiles, users_profiles_on)

      if user
        friendships        = Friendship.arel_table
        users_friends_on   = friendships.create_on(users[:id].eq(friendships.alias[:user_id]))
        users_friends_join = users.create_join(friendships.alias, users_friends_on,
                                               Arel::Nodes::OuterJoin)
        
        distinct.joins(users_profiles_join, users_friends_join).where("profiles.readable in (?) or users.id = ? or friendships_2.friend_id = ? or 0 < (#{User.count_admins(user).to_sql})", ['world', 'community'], user.id, user.id)
      else
        distinct.joins(users_profiles_join).where('profiles.readable = ?', 'world')
      end
    end
  end

  scope :exclude_user, lambda {|user|
    # TODO make this just 'user_id != ?' and verify implementation
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
    # TODO make this a cacched value like the Orgnanization.discovergy, etc
    #   @dummy ||= self.where(email: 'sys@buzzn.net').first
    # and share the hardocded string as constant and the Fabricator and/or
    # db/seeds.rb
    self.where(email: 'sys@buzzn.net').first
  end

  def friend?(user)
    self.friendships.where(friend: user).empty? ? false : true
  end


  # TODO why are those not scopes ?
  def received_friendship_requests
    FriendshipRequest.where(receiver: self)
  end

  def sent_friendship_requests
    FriendshipRequest.where(sender: self)
  end

  def sent_group_register_requests
    GroupRegisterRequest.where(user: self).requests
  end

  def received_group_register_requests
    GroupRegisterRequest.where(user: self).invitations
  end

  def received_register_user_requests
    RegisterUserRequest.where(user: self).invitations
  end

  def old_badge_notifications
    BadgeNotification.where(user: self).read
  end

  def new_badge_notifications
    BadgeNotification.where(user: self).unread
  end



  # TODO all those decorate collections looks like helper methods for the views
  # i.e. does it makes sense to move them into the rails helpers ?
  def editable_registers
    Register::Base.editable_by_user(self).collect(&:decorate)
  end

  def editable_meters
    Meter.editable_by_user(self)
  end

  def editable_groups
    Group::Base.editable_by_user(self).collect(&:decorate)
  end

  def editable_devices
    Device.editable_by_user(self).collect(&:decorate)
  end

  def editable_addresses
    self.editable_registers.collect(&:address).compact.uniq{|address| address.longitude && address.latitude}
  end

  def non_private_editable_registers
    Register::Base.editable_by_user(self).non_privates.collect(&:decorate)
  end

  def registers_as_member
    Register::Base.with_role(:member, self).collect(&:decorate)
  end

  def accessible_registers
    Register::Base.accessible_by_user(self).collect(&:decorate)
  end

  def self.unsubscribed_from_notification(key, resource)
    result = []
    result << NotificationUnsubscriber.by_resource(resource).by_key(key).collect(&:user)
    if resource.is_a?(Group) || resource.is_a?(Register::Base)
      result << NotificationUnsubscriber.within_users(resource.involved).by_key(key).collect(&:user)
    end
    return result.flatten.uniq
  end

  def wants_to_get_notified_by_email?(key, resource)
    NotificationUnsubscriber.by_user(self).by_resource(resource).by_key(key).empty?
  end

  def accessible_groups
    result = []
    result << Group::Base.editable_by_user(self).collect(&:decorate)
    result << self.accessible_registers.collect(&:group).compact.collect(&:decorate)
    return result.flatten.uniq
  end

  def usable_registers
    result = self.editable_registers
    self.friends.each do |friend|
      result << friend.non_private_editable_registers
    end
    return result.flatten.uniq.sort! { |a,b| a.name.downcase <=> b.name.downcase }
  end

  def invitable_users(register)
    result = self.friends.collect(&:profile).compact.collect(&:user)
    not_invitable = []

    register.users.each do |user|
      user.profile.nil? ? nil : not_invitable << user
    end
    return result - not_invitable
  end

  def accessible_registers_by_address
    result = []
    without_address = []
    all_registers = Register::Base.accessible_by_user(self)
    all_addresses = all_registers.collect(&:address).compact.uniq{|address| address.longitude && address.latitude}
    result << {:address => nil, :registers => all_registers} if all_addresses.empty?

    all_addresses.each do |address|
      registers_for_one_address = []
      all_registers.each do |register|
        register_address = register.address
        if register_address == nil
          if !without_address.include?(register)
            without_address << register
          end
          next
        elsif register_address.longitude == address.longitude && register_address.latitude == address.latitude
          registers_for_one_address << register
        end
      end
      result << {:address => address, :registers => registers_for_one_address}
    end
    result << {:address => nil, :registers => without_address} if without_address.any?
    #coordinates = all_addresses.compact.collect{|address| [address.longitude, address.latitude]}.uniq
    #coordinates.each do |coordinate|
    #  addresses = Address.where(longitude: coordinate[0]).where(latitude: coordinate[1])
    #  result << {:address => addresses.first, :registers => addresses.collect(&:register)}
    #end
    #without_address = all_registers.collect{|register| register if register.address.nil?}.compact
    #result << {:address => nil, :registers => without_address} if without_address.any?
    return result
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
      Doorkeeper::AccessToken.create(application_id: application.first.id, resource_owner_id: self.id, scopes: 'simple full' )
    end
  end

  def invoke_invitation_accepted_activity
    self.create_activity(key: 'user.accept_platform_invitation', owner: self, recipient: self.invited_by)
    self.update_attributes(:data_protection_guidelines => I18n.t('data_protection_guidelines_html'), :terms_of_use => I18n.t('terms_of_use_html'))
  end

  def delete_content
    self.editable_groups.each do |group|
      if (group.managers.count == 1 && !group.input_registers.collect{|register| self.can_update?(register)}.include?(false))
        group.destroy
      end
    end
    self.editable_registers.each do |register|
      if register.managers.count == 1 && (register.users.count <= 1 && (register.users.include?(self) || register.users.empty?))
        register.destroy
      end
    end
    RegisterUserRequest.where(user: self).each{|request| request.destroy}
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
