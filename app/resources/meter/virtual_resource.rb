module Meter
  class VirtualResource < BaseResource

    model Virtual

    has_one :register

    def register
      # FIXME here we just bypass the permission check as
      #       a creator of new VirtualMeter has no permissions
      #       to read its register
      Register::VirtualResource.new(object.register)
    end
  end
end
