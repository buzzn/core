class FriendshipResource < ApplicationResource
  has_one :friend
  has_one :user
end
