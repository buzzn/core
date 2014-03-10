class MeterAuthorizer < ApplicationAuthorizer


  def self.readable_by?(user)
    true
  end


  # Class method: can this user at least sometimes create a meter?
  def self.creatable_by?(user)
    true #user.manager?
  end

  # Instance method: can this user delete this particular meter?
  def deletable_by?(user)
    resource.user == user || user.has_role?(:admin)
  end


end