class MeteringPointResource < ApplicationResource

  attributes  :uid,
              :name,
              :mode,
              :readable

  has_many :devices
  has_one :meter
  has_many :users

end
