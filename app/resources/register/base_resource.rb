module Register
  class BaseResource < ApplicationResource
    abstract
    attributes  :uid,
                :mode,
                :name,
                :meter_id,
                :readable

    has_many :devices
    has_many :users
    has_one  :address

  end
end
