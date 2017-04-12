module Register
  class RealSingleResource < SingleResource

    model Real

    attributes  :uid,
                :obis

    has_many :devices

  end

  class RealCollectionResource < CollectionResource

    model Real

  end

  # to satisfy rails autoload
  RealResource = RealSingleResource
end
