require 'buzzn/types/discovergy'

module Buzzn::Discovergy
  class Facade

    INTERVAL_MAP = { second: :raw,
                     hour: :raw,
                     day: :fifteen_minutes,
                     month: :one_day,
                     year: :one_month }

    def initialize
      # hack to bring in API
      @api = Import.global('service.datasource.discovergy.api')
    end

    # This function sends the request to the discovergy API and returns the unparsed response
    # input params:
    #  broker: class with information about credentials and requested meterID
    #  interval: class with information about the beginning and end date
    #  mode: :in or :out to decide which data is requested for a meter
    #  collection: boolean that indicates whether to request data preaggregated or as a collection
    # returns:
    #  Net::HTTPResponse with requested data
    def readings(broker, interval, mode, collection=false)
      return "[]" if collection && !broker.mode.include?(mode.to_s)

      query =
        if interval.nil?
          # for dummies: from a technical point a two way meter is counting
          # either 'in' or 'out' never both at the same time. the direction
          # will be the sign of the value: negative values are 'out' and
          # positive values are 'in'
          Types::Discovergy::LastReading::Get.new(meter: broker.resource,
                                                  fields: ['power'],
                                                  each: collection)
        else
          resolution = INTERVAL_MAP[interval.duration]
          Types::Discovergy::Readings::Get.new(meter: broker.resource,
                                               fields: ['energy', 'energyOut'],
                                               resolution: resolution,
                                               from: interval.from_as_millis,
                                               to: interval.to_as_millis,
                                               each: collection)
        end

      @api.raw_request(query)
    end

    def single_reading(broker, millis, mode)
      query =
          Types::Discovergy::Readings::Get.new(meter: broker.resource,
                                               fields: ['energy', 'energyOut'],
                                               resolution: :raw,
                                               from: millis,
                                               to: millis + 2000)

      @api.raw_request(query)
    end

    def create_virtual_meter(existing_random_broker, meter_ids_plus, meter_ids_minus=[])

      query =
        Types::Discovergy::VirtualMeter::Post.new(meter: broker.resource,
                                                  meter_ids_plus: meter_ids_plus,
                                                  meter_ids_minus: meter_ids_minus)
      @api.raw_request(query)
    end
  end
end
