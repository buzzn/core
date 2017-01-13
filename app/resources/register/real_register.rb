module Register
  class RealRegister < Register::BaseResource
    abstract

    attributes  :uid,
                :obis

    has_many :devices

  end
end
