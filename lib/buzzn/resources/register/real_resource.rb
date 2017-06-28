module Register
  class RealResource < BaseResource

    model Real

    attributes :metering_point_id, :obis

    has_many :devices

  end
end
