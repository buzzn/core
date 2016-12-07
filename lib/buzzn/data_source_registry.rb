module Buzzn

  class DataSourceRegistry

    def initialize(discovergy_data_source = Buzzn::Discovergy::DataSource.new,
                   mysmartgrid_data_source = Buzzn::Mysmartgrid::DataSource.new)
      @discovergy = discovergy_data_source
      @mysmartgrid = mysmartgrid_data_source
    end

    def data_source_for(organization)
      case organization
      when Organization.discovergy
        @discovergy
      when Organization.mysmartgrid
        @mysmartgrid
      else
        raise "do not have a data source for #{organization.inspect}"
      end
    end
  end
end
