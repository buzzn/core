require_relative '../billing'

module Builders::Billing
  class ItemBuilder

    class << self

      def from_contract(contract, register, max_date_range, tariff, start_date_billing: nil, end_date_billing: nil, fail_silent: true)
        date_range = date_range(contract, max_date_range)
        attrs = {
          contract_type:   contract_type(contract),
          date_range:      date_range,
          tariff:          tariff,
          begin_reading:   reading_close_to(register, date_range.first, start_date_billing, end_date_billing, fail_silent: fail_silent),
          end_reading:     reading_close_to(register, date_range.last, start_date_billing, end_date_billing, fail_silent: fail_silent),
          register:        register
        }
        BillingItem.new(attrs)
      end

      private

      # Example: Contract::LocalpoolPowerTaker => 'power_taker'
      def contract_type(contract)
        contract.model_name.name.sub('Contract::Localpool', '').underscore.to_sym
      end

      def date_range(contract, max_date_range)
        begin_date = begin_date(contract, max_date_range.first)
        end_date   = end_date(contract, max_date_range.last)
        begin_date..end_date
      end

      def begin_date(contract, min_begin_date)
        if contract.begin_date < min_begin_date
          min_begin_date
        else
          contract.begin_date
        end
      end

      def end_date(contract, max_end_date)
        if !contract.end_date
          max_end_date
        elsif contract.end_date >= max_end_date
          max_end_date
        else
          contract.end_date
        end
      end

      def reading_close_to(register, date, start_date_billing, end_date_billing, fail_silent: true)
        reading_service = Import.global('services.reading_service')
        begin
          readings = reading_service.get(register, date, :precision => 2.days)
          if readings.nil?
            unless start_date_billing.nil? || end_date_billing.nil?
              reading_start_date_billing = reading_service.get(register, start_date_billing, :precision => 2.days)
              reading_end_date_billing = reading_service.get(register, end_date_billing, :precision => 2.days)
              unless reading_start_date_billing.nil? || reading_end_date_billing.nil?
                consumption_total = reading_end_date_billing.to_a.max_by(&:value).raw_value  - reading_start_date_billing.to_a.max_by(&:value).raw_value
                consumption = (date - start_date_billing)/(end_date_billing - start_date_billing) * consumption_total
                attrs = {
                  raw_value: consumption,
                  date: date
                }
                readings = [register.readings.create(attrs)]
              end
            end
          end
        rescue Buzzn::DataSourceError => error
          if fail_silent
            readings = []
          else
            raise error
          end
        end
        readings.to_a.max_by(&:value) # if there's more than one reading, take the highest one.
      end

    end

  end
end
