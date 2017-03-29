class FriendshipSerializer < ActiveModel::Serializer
  has_one :friend
  has_one :user
end
