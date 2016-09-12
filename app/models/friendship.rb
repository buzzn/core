class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  #scope :send_by_user, ->(user) { where(sender: user) }

  def self.friend_of_roles_query(user, resource_arel, *roles)
    users_roles    = Role.users_roles_arel_table
    role           = Role.arel_table
    friendship     = Friendship.arel_table
    managers = users_roles
               .join(role)
               .on(role[:id].eq(users_roles[:role_id]).and(role[:resource_id].eq(resource_arel[:id])).and(role[:name].in(roles)))
               .where(users_roles[:user_id].eq(friendship[:user_id]))
    manager_friends = friendship.where(friendship[:friend_id].eq(user.id)
                                        .and(managers.project(1).exists))
    manager_friends.project(1).exists
  end
end
