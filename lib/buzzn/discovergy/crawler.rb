module Buzzn::Discovergy

  # the discovergy crawler uses the API from discovergy to retrieve
  # readings and produces a CrawlerResult object
  class Crawler

    def initialize(url, max_concurrent)
      @facade = Facade.new(url, max_concurrent)
    end

    def collection(group, interval, mode)
      result = CrawlerResult.new
      # get the broker with given mode for the group
      # i.e.   DiscovergyBroker.in(group)
      # or     DiscovergyBroker.out(group)
      broker = DiscovergyBroker.send(mode, group)
      response = @facade.virtual_meter(broker, interval)
      #TODO parse response
      result.freeze
      result
    end

    def aggregated(group, interval, mode)
      result = CrawlerResult.new
      # get the broker with given mode for the group
      # i.e.   DiscovergyBroker.in(group)
      # or     DiscovergyBroker.out(group)
      broker = DiscovergyBroker.send(mode, group)
      response = @facade.aggregated_virtual_meter(broker, interval)
      #TODO parse response
      result.freeze
      result
    end

    def single(register, interval)
      result = CrawlerResult.new
      response =
        if register.virtual?
          broker = DiscovergyBroker.virtual(register)
          @facade.virtual_meter(broker, interval)
        else
          @facade.easy_meter(register.meter, interval)
        end
      #TODO parse response
      result.freeze
      result
    end
  end
end
