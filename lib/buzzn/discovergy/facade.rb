require 'buzzn/discovergy/throughput'
module Buzzn::Discovergy
  class Facade

    @@throughput = Throughput.new

    def initialize(login, credentials, url)
      @login = login
      @token = token
      @url   = url
    end

    def virtual_meter(external_id, interval)
      # TODO
    end

    def single_meter(serialnumber, interval)
      # TODO
    end

    def create_virtual_meter(group)
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
    end

    def after
      @@throughput.decrement
    end

  end
end
