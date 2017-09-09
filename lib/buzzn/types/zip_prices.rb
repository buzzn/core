require 'dry-initializer'

module Buzzn
  module Types
    class ZipPrices
      extend Dry::Initializer

      option :zip, Types::Strict::Int
      option :type, MeterTypes
      option :annual_kwh, Types::Strict::Int

      alias :init :initialize
      def initialize(**kwargs)
        init(kwargs)
        @list = ZipToPrice.by_zip(zip).collect do |price|
          ZipPrice.new(price: price, type: type, annual_kwh: annual_kwh)
        end
      end

      def max_price
        result = @list.first
        @list.each do |price|
          result = price if price.total_cents_per_month > result.total_cents_per_month
        end if @list.size > 1
        result
      end
    end
  end
end
