class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user, variant = nil)
    args = [user]
    case variant
    when :meter
      return User.any_role?(user, manager: resource)
    when NilClass
    when :no_group_inheritance
      args << false
    when :group_inheritance
      args << true
    else
      raise 'wrong argument'
    end
    # uses scope MeteringPoint.readable_by(user)
    readable?(MeteringPoint, *args) ||
      # TODO get this into MeteringPoint.readable_by(user)
      (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group))
  end

  def updatable_by?(user, options = {})
    case options
    when :members
      User.any_role?(user, admin: nil, manager: resource, member: resource)
    when Hash
      if options.empty?
        User.any_role?(user, admin: nil, manager: resource)
      else
        if options[:action] == 'edit_devices' || options[:action] == 'edit_users'
          !!user && (user.has_role?(:manager, resource) ||
                     resource.users.include?(user) ||
                     user.has_role?(:admin))
        end
      end
    else
      raise 'wrong argument'
    end
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
