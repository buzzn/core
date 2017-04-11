module Meter
  class VirtualResource < BaseResource

    model Virtual

    has_one :register

    def register
      # FIXME here we just bypass the permission check as
      #       a creator of new VirtualMeter has no permissions
      #       to read its register
      object.register
    end
  end
  
  # TODO get rid of the need of having a Serializer class
  class VirtualSerializer < VirtualResource
  end
end
