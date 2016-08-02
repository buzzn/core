class DeviceAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !! user
  end

  def readable_by?(user)
    old = (resource.output? && resource.metering_point && !!resource.metering_point.group) ||
      !!user && (user.has_role?(:manager, resource) ||
                (!!User.with_role(:manager, resource).first && User.with_role(:manager, resource).first.friend?(user)) ||
               user.has_role?(:admin))
    ng = Device.readable_by(user).where('devices.id = ?', resource.id).select('id').size == 1
    if old != ng
      warn old
      warn Device.readable_by(user).collect {|c| c}
      warn 'legacy query is different from sql query on device#readable_by'
      old
    else
      ng
    end
  end

  def updatable_by?(user)
    user && (user.has_role?(:manager, resource) ||
             user.has_role?(:admin))
  end

  def deletable_by?(user)
    user && (user.has_role?(:manager, resource) ||
             user.has_role?(:admin))
  end

end
