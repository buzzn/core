class ProfileResource < ApplicationResource

  attributes  :slug,
              :user_name,
              :first_name,
              :last_name,
              :md_img


  has_many :groups
  has_many :friendships
  has_many :metering_points
  has_many :devices
end
