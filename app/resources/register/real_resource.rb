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

  class RealFullCollectionResource < FullCollectionResource

    model Real

    attributes  :uid,
                :obis

  end

  # to satisfy rails autoload
  RealResource = RealSingleResource
end
