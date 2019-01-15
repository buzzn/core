module Service
  # This service returns all billing items inside a unbilled date range
  class BillingData

    class << self

      def data(object, **options)
        case object
        when Contract::LocalpoolPowerTaker
          new(object).from_contract(options)
        end
      end

    end

    def initialize(object)
      @object = object
    end

    def from_contract(begin_date:, end_date:)
      contract = @object
      result = {}.tap do |h|
        h[:begin_date] = begin_date
        h[:end_date]   = end_date
        h[:items] = []
      end

      contract.register_meta.registers.each do |register|
        in_range_tariffs = contract.contexted_tariffs.keep_if do |tariff|
          if tariff.end_date.nil?
            tariff.begin_date <= end_date
          else
            tariff.begin_date <= end_date && tariff.end_date >= begin_date
          end
        end
        ranges = []
        # calculate new range for each tariff
        new_max = begin_date
        in_range_tariffs.each do |tariff|
          range = {}
          range[:begin_date] = [tariff.begin_date, new_max].max
          range[:end_date]   = [tariff.end_date || end_date, end_date].min
          range[:tariff]     = tariff.tariff
          ranges << range
        end
        # split even further, split with already existing BillingItems
        existing_billing_items = register.billing_items.in_date_range(begin_date..end_date)
        existing_billing_items.each do |item|
          # search correct range
          ranges.each_with_index do |range, idx|
            if range[:begin_date] <= item.begin_date && range[:end_date] <= item.end_date
              ranges[idx][:end_date] = item.begin_date
              result[:end_date]      = [item.begin_date, result[:end_date]].min
            end
            if range[:begin_date] <= item.begin_date && range[:end_date] > item.end_date
              new_range = range.dup
              new_range[:begin_date] = item.end_date
              ranges[idx][:end_date] = item.begin_date
              ranges << new_range
            end
            if range[:begin_date] > item.begin_date && range[:begin_date] < item.end_date
              # update also params[:begin] here to line up
              result[:begin_date]      = [item.end_date, result[:begin_date]].max
              ranges[idx][:begin_date] = item.end_date
            end
          end

        end

        begin
          ranges.each do |range|
            result[:items] << Builders::Billing::ItemBuilder.from_contract(contract, range[:begin_date]..range[:end_date], range[:tariff])
          end
        rescue Buzzn::DataSourceError => error
          raise Buzzn::ValidationError.new(error.message)
        end
      end
      result
    end
  end
end