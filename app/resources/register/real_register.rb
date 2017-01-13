module Register
  class RealRegister < BaseResource
    model_name 'Register::Real'

    attributes  :uid,
                :obis

    has_many :devices

  end
end
