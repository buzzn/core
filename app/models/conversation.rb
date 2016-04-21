class Conversation < ActiveRecord::Base
  resourcify
  has_many :users, through: :roles, class_name: 'User', source: :users

  include Authority::Abilities
  acts_as_commentable

  scope :with_user, lambda {|user|
    self.with_role(:member, user)
  }

  def members
    self.users
  end

end
