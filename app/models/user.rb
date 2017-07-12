class User < ContractingParty
  rolify
  include Filterable

  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :timeoutable,
         :confirmable, :invitable

  validates :legal_notes, acceptance: true

  acts_as_voter

  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', dependent: :destroy, :foreign_key => :resource_owner_id
  has_many :notification_unsubscribers

  belongs_to :person

  # TODO remove delegates
  delegate :slug, to: :profile
  delegate :name, to: :profile
  delegate :user_name, to: :profile
  delegate :first_name, to: :profile
  delegate :last_name, to: :profile
  delegate :about_me, to: :profile
  delegate :image, to: :profile
  delegate :phone, to: :profile

  # needed to be uniform with organiztion via contracting-party
  def fax; ''; end

  before_destroy :delete_content

  after_invitation_accepted :invoke_invitation_accepted_activity

  validate :nil_profile
  def nil_profile
    if profile.nil? && !roles.empty?
      errors['roles'] = 'without profile the user can not have roles'
    end
  end

  # permissions helpers

  scope :restricted, ->(uuids) { where(id: uuids) }

  def unbound_rolenames
    roles.where(resource_id: nil).collect{ |r| r.name.to_sym }
  end

  def rolename_to_uuids
    roles.where('resource_id IS NOT NULL').each_with_object({}) do |r, obj|
      (obj[r.name.to_sym] ||= []) << r.resource_id
    end
  end

  def uuids_to_rolenames
    roles.where('resource_id IS NOT NULL').each_with_object({}) do |r, obj|
      (obj[r.resource_id] ||= []) << r.name.to_sym
    end
  end

  def rolenames_for(uuid)
    unbound_rolenames + uuids_to_rolenames.fetch(uuid, [])
  end

  def uuids_for(roles)
    map = rolename_to_uuids
    map.values_at(*(roles & map.keys)).flatten
  end

  # other stuff

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
    raise 'TODO'
  end

  def invitable_users(register)
    result = self.friends.collect(&:profile).compact.collect(&:user)
    not_invitable = []

    register.users.each do |user|
      user.profile.nil? ? nil : not_invitable << user
    end
    return result - not_invitable
  end

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




private

  def invoke_invitation_accepted_activity
    self.update_attributes(:data_protection_guidelines => I18n.t('data_protection_guidelines_html'), :terms_of_use => I18n.t('terms_of_use_html'))
  end

  def delete_content
    raise 'TODO'
    dummy_user = User.dummy
    Comment.where(user: self).each do |comment|
      comment.user_id = dummy_user.id
      comment.save
    end

    self.roles.delete_all
  end

end
