module Register
  class RealSerializer < BaseSerializer

    attributes  :uid,
                :obis

    has_many :devices

  end
end
