module Buzzn::StandardProfile
  class DataSource

    def to_map(resource)
      case resource
      when Group
        to_group_map(resource)
      when Register
        to_register_map(resource)
      end
    end

  end
end
