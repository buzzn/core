class UserResource < ApplicationResource

  attributes :email

  has_one :profile
end
