class CommentAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    # uses scope Comment.readable_by(user)
    readable?(Comment, user)
  end

  def updatable_by?(user)
    user == resource.user
  end

  def deletable_by?(user)
    user == resource.user || User.any_role?(user, admin: nil, manager: resource.commentable)
  end

end
