class FriendshipSerializer < ActiveModel::Serializer
  attributes  :id,
              :friend_id,
              :user_id
end
