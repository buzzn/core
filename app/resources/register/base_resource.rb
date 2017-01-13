module Register
  class BaseResource < ApplicationResource
    abstract
    attributes  :direction,
                :name,
                :readable

    has_one  :address
    has_one  :meter

  end
end
