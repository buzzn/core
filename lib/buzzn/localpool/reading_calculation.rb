module Buzzn::Localpool
  class ReadingCalculation
    class << self

      # This method returns the energy measured in a specific period of time
      # input params:
      #   register: The Register::Base for which the energy is requested
      #   begin_date: The Date of the period's beginning
      #   end_date: The Date of the period's ending
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   accounted_energy: The energy accounted in the specified period
      def get_energy_for_period(register, begin_date, end_date, accounting_year=Time.current.year - 1)
        first_reading = get_first_reading(register, begin_date)
      end

      # This method returns the reading used as first reading for following calculations
      # input params:
      #   register: The Register::Base for which the reading is requested
      #   begin_date: The Date of the reading that must be found in the database
      # returns:
      #   first_reading: Reading used as beginning reading for following calculations
      def get_first_reading(register, begin_date)
        if begin_date.nil?
          # try to get the last reading one year ahead of the accounting_year (mostly at 31st December)
          first_reading = Reading.by_register_id(register.id)
                                  .in_year(accounting_year - 1)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .sort('timestamp': -1)
                                  .first
          if first_reading.nil?
            # try to get the first reading in the accounting_year
            first_reading = Reading.by_register_id(register.id)
                                    .in_year(accounting_year)
                                    .without_reason(Reading::DEVICE_CHANGE_2)
                                    .sort('timestamp': 1)
                                    .first
            # if no reading was found in the accounting_year and one year ahead raise an error
            if first_reading.nil?
              raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
            end
          end
        else
          # try to get the the reading exactly at the begin_date
          first_reading = Reading.by_register_id(register.id)
                                  .at(begin_date)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .first
          # if no reading was found at the specific date raise an error
          if first_reading.nil?
            raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
          end
        end
        return first_reading
      end
    end
  end
end