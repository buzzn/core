module Group
  class TribeResource < MinimalBaseResource

    model Tribe

  end

  # TODO get rid of the need of having a Serializer class
  class TribeSerializer < TribeResource
    def self.new(*args)
      super
    end
  end
end
