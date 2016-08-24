class ConversationAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    # TODO ???? why does a Conversation needs to have members
    User.with_role(:member, resource) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    # TODO ???? why does a Conversation needs to have members
     user.has_role?(:admin) ||
     User.with_role(:member, resource)
  end

  def deletable_by?(user)
    user.has_role?(:admin)
  end
end
