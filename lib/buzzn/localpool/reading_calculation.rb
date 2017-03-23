module Buzzn::Localpool
  class ReadingCalculation
    class << self

      # This method returns the energy measured in a specific period of time
      # input params:
      #   register: The Register::Base for which the energy is requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   billing_details: Object, that contains all information about accounted readings and device changes
      def get_energy_for_period(register, begin_date, end_date, accounting_year=Time.current.year - 1)
        first_reading = get_first_reading(register, begin_date, accounting_year)
        last_reading_original = get_last_reading(register, begin_date, accounting_year)
        last_reading = last_reading_original
        if end_date.nil? || end_date > Time.current
          last_reading['timestamp'] = adjust_end_date(last_reading['timestamp'], accounting_year)
        end

        device_change_readings = get_readings_at_device_change(register, begin_date, end_date, accounting_year)
        last_reading['energy_milliwatt_hour'] = adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings, end_date)
        if device_change_readings.empty?
          accounted_energy = last_reading['energy_milliwatt_hour'] - first_reading['energy_milliwatt_hour']
          billing_details = Buzzn::Localpool::AccountedEnergy.new(accounted_energy, first_reading, last_reading)
        else
          device_change = true
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          # if the device change happend exactly on the begin_date just ignore it
          if device_change_reading_1['timestamp'] == first_reading['timestamp'] && device_change_reading_2['timestamp'] != begin_date
            device_change_reading_1['energy_milliwatt_hour'] = 0
            device_change_reading_2['energy_milliwatt_hour'] = 0
            device_change = false
          end
          accounted_energy = last_reading['energy_milliwatt_hour'] - device_change_reading_2['energy_milliwatt_hour'] + device_change_reading_1['energy_milliwatt_hour'] - first_reading['energy_milliwatt_hour']
          billing_details = Buzzn::Localpool::AccountedEnergy.new(accounted_energy, first_reading, last_reading, device_change, device_change_reading_1, device_change_reading_2)
        end
        return billing_details
      end

      # This method returns the reading used as first reading for following calculations
      # input params:
      #   register: The Register::Base for which the reading is requested
      #   begin_date: The Date of the reading that must be found in the database. Can be nil if the beginning is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   first_reading: Reading used as beginning reading for following calculations
      def get_first_reading(register, begin_date, accounting_year)
        if begin_date.nil?
          # try to get the last reading one year ahead of the accounting_year (mostly at 31st December)
          first_reading_ahead = Reading.by_register_id(register.id)
                                  .in_year(accounting_year - 1)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .sort('timestamp': -1)
                                  .first

          # try to get the first reading in the accounting_year
          first_reading_behind = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .sort('timestamp': 1)
                                  .first
          first_reading = select_closest_reading(Date.new(accounting_year, 1, 1), first_reading_ahead, first_reading_behind)
          # if no reading was found in the accounting year or one year ahead raise an error
          if first_reading.nil?
            raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the begin_date
          first_reading = Reading.by_register_id(register.id)
                                  .at(begin_date)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .sort('timestamp': 1)
                                  .first
          # if no reading was found at the specific date raise an error
          if first_reading.nil?
            raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
          end
        end
        return first_reading
      end

      # This method returns the reading used as last reading for following calculations
      # input params:
      #   register: The Register::Base for which the reading is requested
      #   end_date: The Date of the reading that must be found in the database. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   last_reading: Reading used as ending reading for following calculations
      def get_last_reading(register, end_date, accounting_year)
        if end_date.nil?
          # try to get the first reading one year after the accounting_year (mostly beginning of January)
          last_reading_behind = Reading.by_register_id(register.id)
                                  .in_year(accounting_year + 1)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .sort('timestamp': 1)
                                  .first

          # try to get the last reading in the accounting_year
          last_reading_ahead = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .sort('timestamp': -1)
                                  .first
          last_reading = select_closest_reading(Date.new(accounting_year, 12, 31), last_reading_ahead, last_reading_behind)
          if last_reading.nil?
            raise RecordNotFoundError.new("no ending reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the end_date
          last_reading = Reading.by_register_id(register.id)
                                  .at(end_date)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .sort('timestamp': 1)
                                  .first
          # if no reading was found at the specific date raise an error
          if last_reading.nil?
            raise RecordNotFoundError.new("no ending reading found for register #{register.id}")
          end
        end
        return last_reading
      end

      def select_closest_reading(desired_date, reading_ahead, reading_behind)
        if reading_ahead.nil? && !reading_behind.nil?
          return reading_behind
        elsif !reading_ahead.nil? && reading_behind.nil?
          return reading_ahead
        elsif !reading_ahead.nil? && !reading_behind.nil?
          return (reading_ahead['timestamp'].to_date - desired_date).round.abs > (desired_date - reading_behind['timestamp'].to_date).round.abs ? reading_behind : reading_ahead
        else
          return nil
        end
      end

      # This method returns a Time at the end of the year in a desired year
      # input params:
      #   end_date: The Date of the period's ending that has to be adjusted. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   time: the adjusted time
      def adjust_end_date(end_date, accounting_year)
        case end_date.year
        # the end_date is mostly in the beginning of January and has to be set to the 31st of December before.
        when accounting_year + 1
          Time.new(end_date.year - 1, 12, 31).utc
        when accounting_year
          Time.new(end_date.year, 12, 31).utc
        when accounting_year - 1
          Time.new(end_date.year - 2, 12, 31).utc
        else
          raise ArgumentError.new("unable to adjust the end_date #{end_date}.")
        end
      end

      # This method returns the readings if a device change was in the accounting_year
      # input params:
      #   register: The Register::Base for which the readings are requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   device_change_readings: An array of 2 readings at the time of the device change. Is empty if no device change
      def get_readings_at_device_change(register, begin_date, end_date, accounting_year)
        if !begin_date.nil? && end_date.nil?
          device_change_readings = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .where(:timestamp.gt => begin_date)
                                  .by_reason(Reading::DEVICE_CHANGE_1, Reading::DEVICE_CHANGE_2)
                                  .sort('reason': 1)
        elsif !begin_date.nil? && !end_date.nil?
          device_change_readings = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .where(:timestamp.gt => begin_date)
                                  .where(:timestamp.lt => end_date)
                                  .by_reason(Reading::DEVICE_CHANGE_1, Reading::DEVICE_CHANGE_2)
                                  .sort('reason': 1)
        elsif begin_date.nil? && !end_date.nil?
          device_change_readings = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .where(:timestamp.lt => end_date)
                                  .by_reason(Reading::DEVICE_CHANGE_1, Reading::DEVICE_CHANGE_2)
                                  .sort('reason': 1)
        else
          device_change_readings = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .by_reason(Reading::DEVICE_CHANGE_1, Reading::DEVICE_CHANGE_2)
                                  .sort('reason': 1)
        end
        return device_change_readings
      end

      # This method inter- or extrapolates the last_reading's energy value
      # input params:
      #   first_reading: The first reading that will be taken into account
      #   last_reading: The last reading the will be adjusted
      #   last_reading_original: The original last reading that would have been taken into account if its date would match
      #   device_change_readings: Array with 2 readings from a device_change. May be empty.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      # returns:
      #   last_reading['energy_milliwatt_hour']: The adjusted energy value that has to be set to the last reading
      def adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings, end_date)
        if device_change_readings.empty?
          # only adjust the reading if the timestamps differ AND there is no end_date (because if there was and end_date we want exactly that date and not adjust it!)
          if last_reading['timestamp'] != last_reading_original['timestamp'] && end_date.nil?
            timedifference_original = (last_reading['timestamp'].to_date - last_reading_original['timestamp'].to_date).round
            if timedifference_original != 0
              timespan = (last_reading['timestamp'].to_date - first_reading['timestamp'].to_date).round
              last_reading['energy_milliwatt_hour'] += timedifference_original * (last_reading['energy_milliwatt_hour'] - first_reading['energy_milliwatt_hour']) * 1.0 / timespan
            end
          end
        else
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          # only adjust the reading if the timestamps differ AND there is no end_date (because if there was and end_date we want exactly that date and not adjust it!)
          if last_reading['timestamp'] != last_reading_original['timestamp'] && end_date.nil? #TODO: is the 2nd check needed? I think so but it was not in the BK source code
            timedifference_original = (last_reading['timestamp'].to_date - last_reading_original['timestamp'].to_date).round
            if timedifference_original != 0
              timespan = (last_reading['timestamp'].to_date - device_change_reading_2['timestamp'].to_date).round
              if device_change_reading_2['timestamp'] == last_reading_original['timestamp']
                last_reading['energy_milliwatt_hour'] = timedifference_original * (device_change_reading_1['energy_milliwatt_hour'] - first_reading['energy_milliwatt_hour']) * 1.0 / timespan + device_change_reading_2['energy_milliwatt_hour']
              else
                last_reading['energy_milliwatt_hour'] += timedifference_original * (last_reading['energy_milliwatt_hour'] - device_change_reading_2['energy_milliwatt_hour']) * 1.0 / timespan
              end
            end
          end
        end
        return last_reading['energy_milliwatt_hour']
      end
    end
  end
end