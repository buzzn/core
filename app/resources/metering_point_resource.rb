class MeteringPointResource < ApplicationResource

  attributes  :uid,
              :name,
              :mode,
              :readable,
              :meter_id

  has_many :devices
  has_many :users
  has_one  :address

end
