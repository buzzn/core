class Conversation < ActiveRecord::Base
  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users

  include Authority::Abilities
  acts_as_commentable

  include PublicActivity::Model
  tracked except: [:create, :update, :destroy], owner: Proc.new{ |controller, model| controller && controller.current_user }

  scope :with_user, lambda {|user|
    self.with_role(:member, user)
  }

  def members
    self.users
  end

  def name
    self.members.collect(&:name).join(", ")
  end

end
