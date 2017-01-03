module Buzzn::Mysmartgrid
  class DataSource

    NAME = :my_smart_grid

    def collection(group_or_virtual_register, mode)
      nil
    end

    def single_aggregated(register_or_group, mode)
      nil
    end

    def aggregated(register_or_group, mode, interval)
      nil
    end
  end
end
