class CommentAuthorizer < ApplicationAuthorizer

  def self.readable_by?(user)
    true
  end

  def self.creatable_by?(user)
    true
  end

  def updatable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.commentable) ||
    user == resource.user
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.commentable) ||
    user == resource.user
  end

end
