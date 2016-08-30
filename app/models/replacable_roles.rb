module ReplacableRoles

  def replace_managers(ids, current_user = nil, public_activity = nil)
    new_managers = User.where(id: ids)
    old_managers = managers.dup
    (old_managers - new_managers).each do |user|
      user.remove_role(:manager, self)
    end
    (new_managers - old_managers).each do |user|
      user.add_role(:manager, self)
      if public_activity && current_user
        user.create_activity(key: public_activity, owner: current_user, recipient: self)
      end
    end
  end
end
