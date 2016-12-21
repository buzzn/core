module Buzzn

  class CheckTypesDataSource < DataSource

    def collection(resource, mode)
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group or Register' if !resource.is_a?(Group) && !resource.is_a?(Register)
      raise 'Register needs to be virtual' if resource.is_a?(Register) && resource.virtual == false
      nil
    end

    def single_aggregated(resource, mode)
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group or Register' if !resource.is_a?(Group) && !resource.is_a?(Register)
      nil
    end

    def aggregated(resource, mode, interval)
      raise 'interval is nil' unless interval
      raise 'mode is nil' unless mode
      raise 'resource is nil' unless resource
      raise 'resource not a Group or Register' if !resource.is_a?(Group) && !resource.is_a?(Register)
      raise 'Register must not be virtual' if resource.is_a?(Register) && resource.virtual == false
      nil
    end
  end
end
