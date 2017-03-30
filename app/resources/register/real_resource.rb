module Register
  class RealResource < BaseResource

    model Real

    attributes  :uid,
                :obis

    has_many :devices

  end

  # TODO get rid of the need of having a Serializer class
  class RealSerializer < RealResource
    def self.new(*args)
      super
    end
  end
end
