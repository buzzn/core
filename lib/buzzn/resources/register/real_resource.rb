module Register
  class RealResource < BaseResource

    model Real

    attributes  :uid,
                :obis

    has_many :devices

  end
end
