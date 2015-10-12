class UserResource < ApplicationResource

  attributes  :slug,
              :user_name,
              :first_name,
              :last_name,
              :about_me,
              :md_img

  has_many :groups
  has_many :friends
  has_many :metering_points
  has_many :devices
end
