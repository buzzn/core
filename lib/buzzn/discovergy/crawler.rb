module Buzzn::Discovergy

  # the discovergy crawler uses the API from discovergy to retrieve
  # readings
  class Crawler

    def initialize(url, max_concurrent)
      @facade = Facade.new(url, max_concurrent)
    end

    def collection(group, interval, mode)
      result = CrawlerResult.new
      # get the broker with given mode for the group
      broker = DiscovergyBroker.send(mode, group)
      response = @facade.virtual_meter(broker, interval)
      #parse response
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
      #parse response
      result
    end
  end
end
