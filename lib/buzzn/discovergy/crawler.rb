module Buzzn::Discovergy
  class Crawler

    def initialize
      @facade = Facade.new
    end

    def virtual_meter(external_id, interval)
      result = CrawlerResult.new
      response = @facade.virtual_meter(external_id, interval)
      #parse response
      result
    end

    def single_meter(serialnumber, interval)
      result = CrawlerResult.new
      response = @facade.single_meter(serialnumber, interval)
      #parse response
      result
    end
  end
end
