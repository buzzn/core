class UserResource < ApplicationResource

  # no attributes they will accessible via profile

  has_one :profile
  has_many :groups
  has_many :friends
  has_many :registers
  has_many :devices
end
