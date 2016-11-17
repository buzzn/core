require 'buzzn/discovergy/throughput'
module Buzzn::Discovergy
  class Facade

    @@throughput = Throughput.new

    def initialize(url, max_concurrent)
      @url   = url
      @max_concurrent = max_concurrent
    end

    def virtual_meter(broker, interval)
      # TODO
    end

    def easy_meter(meter, interval)
      # TODO
    end

    def create_virtual_meter(group, mode)
      # TODO
    end

    [:virtual_meter, :single_meter, :create_virtual_meter].each do |method|

      alias :"do_#{method}" :"#{method}"

      define_method method do |*args|
        before
        begin
          send(:"do_#{method}", *args)
        ensure
          after
        end
      end

      private method
    end

    private

    def before
      ActiveRecord::Base.clear_active_connections!
      @@throughput.increment
      if @@throughput.current > @max_concurrent
        raise CrawlerError.new('discovergy limit reached')
      end
    end

    def after
      @@throughput.decrement
    end

  end
end
