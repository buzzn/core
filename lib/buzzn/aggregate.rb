require 'buzzn'
require 'buzzn/discovergy/crawler'

module Buzzn

  class AggregateError < StandardError; end

  class AggregateResult < Array

    class AggregateResultItem

      attr_reader :timestamp, :value, :type

      def initialize(timestamp, value, type)
        unless [:energy_milliwatt_hour, :power_milliwatt,
                :energy_b_milliwatt_hour, :energy_a_milliwatt_hour].include?(type)
          raise "unknown type #{type}"
        end
        @timestamp = timestamp
        @type = type
        @value = value
      end
    end

    def add(timestamp, value, type)
      add(AggregateResultItem.new(timestamp, value, type)
    end
  end

  class Aggregate

    def initialize(cralwer_factory)
      @factory = crawler_factory
    end

    def register(interval, register)
      organization = register.metering_point_operator_contract.organization

      if organization
        crawler = @facotry.crawler_for(organization)
        # TODO
      end
    end

    def group(interval, group)
      # TODO needs query to collect all distinct organizations from all
      #      registers of a group
      group.register_organizations.each do |organization|
         crawler = @facotry.crawler_for(organization)
         # aggregate results from crawler ....
      end
    end

    def each_register(interval, group)
      # TODO needs query to collect all distinct organizations from all
      #      registers of a group
      group.register_organizations.each do |organization|
         crawler = @facotry.crawler_for(organization)
         # aggregate results from crawler ....
      end
    end

  end
end
