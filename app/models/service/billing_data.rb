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

    def blow_ranges_vat(ranges, vats)
      result = []
      vats  = vats.clone
      vat = vats.pop
      while ranges.any?
        range = ranges[0]
        vat = vats.pop while vats.any? && vat.begin_date <= range[:begin_date]

        if vat.begin_date >= range[:end_date] || vat.begin_date <= range[:begin_date]
          result.push(ranges.shift)
          next
        else
          head = range.clone
          head[:end_date] = vat.begin_date
          range[:begin_date] = vat.begin_date
          result.push(head)
        end
      end

      result
    end

    def from_contract(begin_date:, end_date:, vats:)
      # We need the active vat to be the last.
      vats = vats.to_a.sort_by(&:begin_date).reverse
      contract = @object
      result = {}.tap do |h|
        h[:begin_date] = begin_date
        h[:end_date]   = end_date
        h[:items] = []
      end

      contract.register_meta.registers.each do |register|
        register_begin_date = [begin_date, register.installed_at&.date || begin_date].max
        register_end_date   = [end_date,   register.decomissioned_at&.date || end_date].min
        in_range_tariffs = contract.contexted_tariffs.keep_if do |tariff|
          # last tariff or single tariff
          if tariff.end_date.nil?
            tariff.begin_date <= register_end_date
          else
            tariff.begin_date <= register_end_date && tariff.end_date > register_begin_date
          end
        end
        ranges = []
        # calculate new range for each tariff
        new_max = register_begin_date
        in_range_tariffs.each do |tariff|
          range = {}
          range[:begin_date] = [tariff.begin_date, new_max].max
          range[:end_date]   = [tariff.end_date || register_end_date, register_end_date].min
          range[:tariff]     = tariff.tariff
          if range[:begin_date] < range[:end_date]
            ranges << range
          end
        end

        ranges = blow_ranges_vat(
          ranges.sort_by {|r| r[:begin_date]},
          vats
        )

        # split even further, split with already existing BillingItems
        existing_billing_items = register.billing_items.in_date_range(register_begin_date..register_end_date)
        existing_billing_items.each do |item|
          # search correct range
          ranges.each_with_index do |range, idx|
            # [ range ]
            #    [ item ]
            if item.begin_date >= range[:begin_date] && item.begin_date < range[:end_date] && item.end_date >= range[:end_date]
              ranges[idx][:end_date] = item.begin_date
              next
            end
            #   [ range ]
            # [ item ]
            if item.begin_date <= range[:begin_date] && item.end_date > range[:begin_date] && item.end_date <= range[:end_date]
              ranges[idx][:begin_date] = item.end_date
              next
            end
            # [   range   ]
            #    [ item ]
            if range[:begin_date] <= item.begin_date && range[:end_date] > item.end_date
              new_range = range.dup
              new_range[:begin_date] = item.end_date
              #new_range[:end_date]   = new_range[:end_date]
              ranges[idx][:end_date] = item.begin_date
              ranges << new_range
              next
            end
          end
          ranges.delete_if { |r| (r[:end_date]-r[:begin_date]).zero? }
          result[:begin_date] = ranges.collect { |r| r[:begin_date] }.min || result[:begin_date]
          result[:end_date]   = ranges.collect { |r| r[:end_date]   }.max || result[:end_date]
        end

        ranges.each do |range|
          # The current vat is the most recent, which has been valid before the billing item range.
          vat = vats.filter {|v| v.begin_date <= range[:begin_date]}.first
          result[:items] << Builders::Billing::ItemBuilder.from_contract(contract, register, range[:begin_date]..range[:end_date], range[:tariff], vat, :fail_silent => true)
        end
      end
      result
    end

  end
end
