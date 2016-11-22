require 'buzzn'
require 'buzzn/discovergy/crawler'

module Buzzn

  class AggregateError < StandardError; end

  class TypedResult < Array

    attr_reader :type

    def initialize(type)
      unless [:energy_milliwatt_hour,
              :power_milliwatt,
              :energy_b_milliwatt_hour,
              :energy_a_milliwatt_hour].include?(type)
          raise "unknown type #{type}"
        end
      @type = type
      super()
    end

    
    def finallize
      freeze
      self
    end
  end


  class PastResult < TypedArray

    class PastItem

      attr_reader :timestamp, :value

      def initialize(timestamp, value)
        @timestamp = timestamp
        @value = value
      end
    end

    def add_value(timestamp, value)
      add(PastItem.new(timestamp, value))
    end 
  end

  class PresentResult < TypedArray

    class PresentItem < PastItem

      attr_reader :operator,:timestamp, :value

      def initialize(timestamp, value, operator)
        @timestamp = timestamp
        @value = value
        @operator = operator
      end
    end

    attr_reader :sum, :timestamp

    def add_reading(timestamp, value, operator)
      add(PresentItem.new(timestamp, value, operator))
    end

    def finallize
      # TODO calculate sum and timestamp from entries
      super
    end
  end

  class Aggregate

    def initialize(cralwer_factory)
      @factory = crawler_factory
    end

    # same as the current aggregate API
    def register(interval, register)
      result = result_for(interval)

      # TODO organization or data_source
      organization = register.metering_point_operator_contract.organization

      if organization
        crawler = @facotry.crawler_for(organization)
        # TODO
      end

      result.finalize
    end

    # not sure if needed but for present sum of the whole group ?!?
    def group(interval, group)
      # TODO needs query to collect all distinct organizations from all
      #      registers of a group
      group.register_organizations.each do |organization|
         crawler = @facotry.crawler_for(organization)
         # aggregate results from crawler ....
      end
    end

    # for wobbly bubbles
    def each_register(interval, group)
      result = result_for(interval)
      # TODO needs query to collect all distinct organizations from all
      #      registers of a group
      #      or is the data_source the one to go from here but what about
      #      the crawler ....
      group.register_organizations.each do |organization|
         crawler = @factory.crawler_for(organization)
         # aggregate results from crawler ....
         # or first collect all results from all crawler and do th e aggregation
      end
      result.finalize
    end

    private

    def result_for(interval)
      interval.live? ? PresentResult.new : PastResult.new
    end
  end
end
