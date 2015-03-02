class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource) ||
    user.has_role?(:manager, resource.root) ||
    User.with_role(:manager, resource).first.friend?(user)
  end


  def updatable_by?(user, options = {})
    if options.empty?
      user.has_role?(:admin) ||
      user.has_role?(:manager, resource) ||
      user.has_role?(:manager, resource.root)
    else
      if options[:action] == 'edit_devices' || options[:action] == 'edit_users'
        user.has_role?(:admin) ||
        user.has_role?(:manager, resource) ||
        user.has_role?(:manager, resource.root) ||
        resource.users.include?(user)
      end
    end
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource) ||
    user.has_role?(:manager, resource.root)
  end

end