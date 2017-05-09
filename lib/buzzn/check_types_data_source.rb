module Buzzn

  class CheckTypesDataSource < DataSource

    NAME = :check

    def collection(resource, mode)
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group::MinimalBaseResource or Register::BaseResource' if !resource.is_a?(Group::Base) && !resource.is_a?(Register::Base) && !resource.is_a?(Group::MinimalBaseResource) && !resource.is_a?(Register::BaseResource)
      raise 'Register must not be virtual' if resource.is_a?(Register::Virtual)
      nil
    end

    def single_aggregated(resource, mode)
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group::MinimalBaseResource or Register::BaseResource' if !resource.is_a?(Group::Base) && !resource.is_a?(Register::Base) && !resource.is_a?(Group::MinimalBaseResource) && !resource.is_a?(Register::BaseResource)
      nil
    end

    def aggregated(resource, mode, interval)
      raise 'interval is nil' unless interval
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group::MinimalBaseResource or Register::BaseResource' if !resource.is_a?(Group::Base) && !resource.is_a?(Register::Base) && !resource.is_a?(Group::MinimalBaseResource) && !resource.is_a?(Register::BaseResource)
      raise 'Register must not be virtual' if resource.is_a?(Register::Virtual)
      nil
    end
  end
end
