class DeviceAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !! user
  end

  def readable_by?(user)
    # uses scope Device.readable_by(user)
    readable?(Device, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
