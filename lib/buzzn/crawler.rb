require 'buzzn'
require 'buzzn/discovergy/crawler'

module Buzzn

  class CrawlerError < StandardError; end

  class CrawlerResult < Array

    class CrawlerResultItem

      attr_reader :timestamp, :power

      def initialize(timestamp, power)
        @timestamp = timestamp
        @power = power
      end
    end

    def add(timestamp, power)
      add(CrawlerResultItem.new(timestamp, power))
    end
  end

  class CrawlerFactory

    def initialize(discovergy_url, max_concurent_discovergy_requests)
      @discovergy = Buzzn::Discovergy::Crawler.new(discovergy_url,
                                                   max_concurent_discovergy_requests)
      @mysmartgrid = Buzzn::Mysmartgrid::Crawler.new
    end

    def crawler_for(organization)
      case organization
      when Organization.discovergy
        @discovergy
      when Organization.mysmartgrid
        @mysmartgrid
      else
        raise "do not have a crawler for #{organization.inspect}"
      end
    end

  end
end
