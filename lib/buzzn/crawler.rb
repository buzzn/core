require 'buzzn'
require 'buzzn/discovergy/crawler'

module Buzzn

  class CrawlerError < StandardError; end

  class CrawlerResult

    def initialize
      @data = []
    end

    def add(timestamp, power)
      @data << timestamp
      @data << power
    end

    def get(i = 0)
      [@data[2 * i], @data[2 * i + 1]]
    end

    def timestamp(i = 0)
      @data[2 * i]
    end

    def power(i = 0)
      @data[2 * i + 1]
    end
  end

  class Crawler

    def self.discovergy
      #TODO retrieve config from somewhere
      Buzzn::Discovergy::Crawler.new(nil, 1)
    end

    @@discovergy = discovergy
    @@mysmartgrid = Buzzn::Mysmartgrid::Crawler.new

    def self.new(organization)
      case organization.name
      when Organization.DISCOVERGY
        @@discovergy
      when Organization.MYSMARTGRID
        @@mysmartgrid
      else
        raise "do not have a crawler for #{organization.name}"
      end
    end

  end
end
