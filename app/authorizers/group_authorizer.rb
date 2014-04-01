class GroupAuthorizer < ApplicationAuthorizer


  def self.readable_by?(user)
    true
  end

  # Class method: can this user at least sometimes create a Group?
  def self.creatable_by?(user)
    true #user.manager?
  end

  def self.updatable_by?(user)
    true
  end


end