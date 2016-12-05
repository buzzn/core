require 'buzzn'
require 'buzzn/discovergy/crawler'

module Buzzn

  class DataSourceRegistry

    def initialize(discovergy_url, max_concurent_discovergy_requests)
      @discovergy = Buzzn::Discovergy::DataSource.new(discovergy_url,
                                                   max_concurent_discovergy_requests)
      @mysmartgrid = Buzzn::Mysmartgrid::DataSource.new
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
