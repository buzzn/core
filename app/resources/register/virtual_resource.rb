module Register
  class VirtualResource < BaseResource

    model Virtual

  end

  # TODO get rid of the need of having a Serializer class
  class VirtualSerializer < VirtualResource
    def self.new(*args)
      super
    end
  end
end
