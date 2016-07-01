class MeteringPointResource < ApplicationResource

  attributes  :uid,
              :name,
              :mode,
              :meter_id,
              :readable, :updateable, :deletable

  has_many :devices
  has_many :users
  has_one  :address

end
