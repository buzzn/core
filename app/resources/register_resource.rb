class RegisterResource < ApplicationResource

  attributes  :uid,
              :name,
              :meter_id,
              :readable

  has_many :devices
  has_many :users
  has_one  :address

end
