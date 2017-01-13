class FriendshipResource < JSONAPI::Resource
  has_one :friend
  has_one :user
end
