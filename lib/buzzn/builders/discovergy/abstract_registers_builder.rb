require_relative 'abstract_builder'

module Builders::Discovergy
  class AbstractRegistersBuilder < AbstractBuilder

    option :registers

    private

    def map
      @map ||= registers.each_with_object({}) do |r, map|
        list = map["EASYMETER_#{r.meter.product_serialnumber}"] ||= []
        list << r
      end
    end

  end
end
