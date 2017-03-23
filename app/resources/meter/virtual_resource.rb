module Meter
  class VirtualResource < BaseResource

    model Meter::Virtual

    has_one :register

    def register
      # FIXME here we just bypass the permission check as
      #       a creator of new VirtualMeter has no permissions
      #       to read its register
      object.register
    end
  end
end
