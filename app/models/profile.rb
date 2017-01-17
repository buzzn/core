require 'file_size_validator'
require 'buzzn/guarded_crud'
class Profile < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Buzzn::GuardedCrud

  extend FriendlyId
  friendly_id :user_name, use: [:slugged, :history, :finders]

  default_scope { order('created_at ASC') }

  mount_uploader :image, PictureUploader

  belongs_to :user

  validates :user_name, presence: true, uniqueness: true, length: { in: 2..63 }
  validates :first_name, presence: true, length: { in: 2..30 }
  validates :last_name, presence: true, length: { in: 2..30 }

  #validates :terms, acceptance: true

  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }

  normalize_attributes :user_name, :first_name, :last_name

  delegate :friends, to: :user
  delegate :friendships, to: :user
  delegate :groups, to: :user

  after_destroy do
    user.roles.delete_all
    user.update(profile: nil)
  end

  scope :readable_by, -> (user) do
    if user
      profiles   = Profile.arel_table
      friendship = Friendship.arel_table

      users_friends_on = friendship.create_on(profiles[:user_id].eq(friendship[:user_id]))
      users_friends_join = profiles.create_join(friendship, users_friends_on, Arel::Nodes::OuterJoin)

      distinct.joins(users_friends_join).where("profiles.readable in (?) or profiles.user_id=? or friendships.friend_id = ? or 0 < (#{User.count_admins(user).to_sql})", ['world', 'community'], user.id, user.id)
    else
      where(readable: 'world')
    end
  end
  # replaces the email with 'hidden@buzzn.net' for all registers which are
  # not readable_by without delegating the check to the underlying group
  scope :anonymized, -> (user) do
    if user.nil?
      select("profiles.*, 'hidden@buzzn.net' AS anonymized_email").joins(:user)
    else
      # admins
      admins    = User.roles_query(user, admin: nil).project(1).exists

      profile   = Profile.arel_table
      sql       = Profile.select(:id).where(admins.or(profile[:user_id].eq(user.id)).to_sql).to_sql

      # with AR5 you can use left_outer_joins directly
      # `left_outer_joins(:user)` instead of this user_on and user_join
      user      = User.arel_table
      user_on   = user.create_on(user[:id].eq(profile[:user_id]))
      user_join = user.create_join(user, user_on, Arel::Nodes::OuterJoin)
      select("profiles.*, CASE WHEN profiles.id NOT IN (#{sql}) THEN 'hidden@buzzn.net' ELSE users.email END AS anonymized_email").joins(user_join)
    end
  end

  scope :anonymized_readable_by, ->(user) do
    readable_by(user).anonymized(user)
  end

  def self.anonymized_get(id, user)
    result = self.where(id: id).anonymized_readable_by(user).first
    if result
      result
    elsif self.where(id: id).first
      # we have record but is not readable by user
      nil #TODO make an exception instead and catch in grape
    else
      # no such record
      raise(ActiveRecord::RecordNotFound.new "#{self} not found for id #{id}")
    end
  end

  def email
    if attribute_names.include? 'anonymized_email'
      anonymized_email
    elsif user
      user.email
    end
  end

  def email=(val)
    user.email = val if user
  end

  def generate_username
    if first_name && last_name && user_name.nil?
      new_user_name = first_name.downcase + last_name.downcase
      #profiles = Profile.where(user_name: new_user_name)
      profiles = Profile.where('user_name ~* ?', new_user_name + '(?:\d+$|)').order(:user_name)
      if profiles.any?
        max = 0
        profiles.each do |profile|
          number = profile.user_name[/\d+$/].to_i
          number > max ? max = number : nil
        end
        self.user_name = new_user_name + (max+1).to_s
      else
        self.user_name = new_user_name
      end
    end
  end

  def should_generate_new_friendly_id?
    self.generate_username
    slug.blank? || user_name_changed?
  end

  # def registers
  #   registers = []
  #   registers << self.user.registers # as member
  #   registers << Register::Base.editable_by_user(self.user) # as manager
  #   registers.compact.flatten.uniq
  # end

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

  def self.readables
    ['friends', 'world', 'members', 'community']
  end

  def readable_by_friends?
    self.readable == 'friends'
  end

  def readable_by_world?
    self.readable == 'world'
  end

  def readable_by_members?
    self.readable == 'members'
  end

  def readable_by_community?
    self.readable == 'community'
  end


end
