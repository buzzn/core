class RegisterResource < ApplicationResource

  attributes  :uid,
              :name,
              :mode,
              :meter_id,
              :readable

  has_many :devices
  has_many :users
  has_one  :address

end
