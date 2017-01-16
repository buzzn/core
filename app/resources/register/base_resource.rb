module Register
  class BaseResource < JSONAPI::Resource
    model_name 'Register::Base'

    attributes  :direction,
                :name,
                :readable

    has_one  :address
    has_one  :meter

  end
end
