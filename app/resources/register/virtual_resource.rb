module Register
  class VirtualSingleResource < SingleResource

    model Virtual

  end

  class VirtualCollectionResource < CollectionResource

    model Virtual

  end

  class VirtualFullCollectionResource < FullCollectionResource

    model Virtual

  end

  # to satisfy rails autoload
  VirtualResource = VirtualSingleResource
end
