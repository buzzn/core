module ReplacableRoles

  def managers
    User.users_of(self, :manager)
  end

  def replace_managers(ids, options = {})
    replace_role_users(ids, self.managers.dup, :manager, options)
  end

  def replace_members(ids, options = {})
    replace_role_users(ids, self.members.dup, :member, options)
  end

  def replace_role_users(ids, old_ones, role, options)
    new_ones = User.where(id: ids)
    (old_ones - new_ones).each do |user|
      user.remove_role(role, self)
      if options[:cancel_key]
        if options[:owner]
          user.create_activity(key: options[:cancel_key],
                               owner: options[:owner],
                               recipient: self)
        else
          self.create_activity(key: options[:cancel_key], owner: user)
        end
      end
    end
    (new_ones - old_ones).each do |user|
      user.add_role(role, self)
      if options[:create_key]
        if options[:owner]
          user.create_activity(key: options[:create_key],
                               owner: options[:owner],
                               recipient: self)
        else
          self.create_activity(key: options[:create_key], owner: user)
        end
      end
    end
  end
  private :replace_role_users
end
