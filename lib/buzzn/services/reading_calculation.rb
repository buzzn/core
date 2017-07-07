# coding: utf-8
module Buzzn
  module Services
    class ReadingCalculation

      include Import['service.charts']

      # This method returns the energy measured for each register in the localpool in a specific period of time
      # input params:
      #   localpool: The Group::Localpool for which the energy is requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   result: TotalAccountedEnergy with details about each single register
      def get_all_energy_in_localpool(localpool, begin_date, end_date, accounting_year=Time.current.year - 1)
        result = Buzzn::Localpool::TotalAccountedEnergy.new(localpool)
        register_id_grid_consumption_corrected = nil
        register_id_grid_feeding_corrected = nil

        localpool.registers.each do |register|
          if register.consumption?
            energy_by_contract = get_register_energy_by_contract(register, begin_date, end_date, accounting_year)
            [Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG,
             Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG,
             Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].each do |consumption_type|
              energy_by_contract[consumption_type].each do |accounted_energy|
                accounted_energy.label = consumption_type
                result.add(accounted_energy)
              end
            end
          elsif register.grid_consumption_corrected?
            register_id_grid_consumption_corrected = register.id
          elsif register.grid_feeding_corrected?
            register_id_grid_feeding_corrected = register.id
          else
            accounted_energy = get_register_energy_for_period(register, begin_date, end_date, accounting_year)
            accounted_energy.label = accounted_energy.first_reading.register.label
            result.add(accounted_energy)
          end
        end
        grid_consumption_corrected, grid_feeding_corrected = calculate_corrected_grid_values(result, register_id_grid_consumption_corrected, register_id_grid_feeding_corrected)
        result.add(grid_consumption_corrected)
        result.add(grid_feeding_corrected)
        return result
      end

      # This method returns the energy measured in a specific period of time for all contracts attached to the register
      # input params:
      #   register: The Register::Base for which the energy is requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   result: Hash with both the accounted energy for all LSN and for all third party supplied parties related to the register
      def get_register_energy_by_contract(register, begin_date, end_date, accounting_year)
        contracts = register.contracts.localpool_power_takers.running_in_year(accounting_year).to_a +
                      register.contracts.other_suppliers.running_in_year(accounting_year).to_a
        begin_date_query = nil
        end_date_query = nil
        result = {}
        consumption_lsn_full_eeg = []
        consumption_lsn_reduced_eeg = []
        consumption_third_party = []
        contracts.each do |contract|
          if contract.begin_date && contract.begin_date.year >= accounting_year
            begin_date_query = contract.begin_date
          else
            begin_date_query = begin_date
          end
          if contract.end_date && contract.end_date.year <= accounting_year
            end_date_query = contract.end_date
          else
            end_date_query = end_date
          end
          accounted_energy = get_register_energy_for_period(contract.register, begin_date_query, end_date_query, accounting_year)
          if contract.is_a?(Contract::OtherSupplier)
            consumption_third_party << accounted_energy
          else
            if contract.renewable_energy_law_taxation == Contract::RenewableEnergyLawTaxation::FULL
              consumption_lsn_full_eeg << accounted_energy
            else
              consumption_lsn_reduced_eeg << accounted_energy
            end
          end
        end
        result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG] = consumption_lsn_full_eeg
        result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG] = consumption_lsn_reduced_eeg
        result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY] = consumption_third_party
        return result
      end

      # This method calculates the accounted energy (both grid consumption and feeding) in dependency of the energy consumed by third party supplied
      # input params:
      #   total_accounted_energy: The TotalAaccountedEnergy of a LCP
      #   register_id_grid_consumption_corrected: The register.id of the LCP's register with label Register::Base::GRID_CONSUMPTION_CORRECTED
      #   register_id_grid_feeding_corrected: The register.id of the LCP's register with label Register::Base::GRID_FEEDING_CORRECTED
      # returns:
      #   2x accounted_energy: Object, that contains all information about accounted readings
      def calculate_corrected_grid_values(total_accounted_energy, register_id_grid_consumption_corrected, register_id_grid_feeding_corrected)
        if register_id_grid_consumption_corrected.nil? || register_id_grid_feeding_corrected.nil?
          raise ArgumentError.new("No corrected ÜGZ registers can be found.")
        end
        consumption_third_party = total_accounted_energy.sum_and_group_by_label[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY]
        grid_consumption = total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).value
        grid_consumption_corrected = grid_consumption - consumption_third_party > 0 ? grid_consumption - consumption_third_party : 0
        grid_consumption_corrected_result = create_corrected_reading(register_id_grid_consumption_corrected, Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED, grid_consumption_corrected, total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).last_reading.timestamp)
        grid_feeding_corrected = grid_consumption - consumption_third_party > 0 ? total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING).value : total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING).value - grid_consumption + consumption_third_party
        grid_feeding_corrected_result = create_corrected_reading(register_id_grid_feeding_corrected, Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED, grid_feeding_corrected, total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING).last_reading.timestamp)
        return grid_consumption_corrected_result, grid_feeding_corrected_result
      end

      # This method creates the new reading for a corrected register and returns the accounted energy for it
      # input params:
      #   register_id: The Register::Base.id for which the reading should be created
      #   label: The label for the accounted energy, may be Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED or Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED
      #   corrected_value: the energy in milliwatt_hour that is used for the new reading
      #   timestamp: The timestamp for the new reading
      # returns:
      #   accounted_energy: Object, that contains all information about accounted readings
      def create_corrected_reading(register_id, label, corrected_value, timestamp)
        # TODO: (nice-to-have) validate that all corrected registers must have an initial reading with energy_milliwatt_hour = 0
        last_corrected_reading = Reading.by_register_id(register_id).sort('timestamp': -1).first
        if last_corrected_reading.nil?
          new_reading = save_corrected_reading(register_id, corrected_value, timestamp)
        else
          if last_corrected_reading.timestamp != timestamp
            new_reading = save_corrected_reading(register_id, corrected_value + last_corrected_reading.energy_milliwatt_hour, timestamp)
          else
            # TODO: maybe think about overwriting an existing reading instead of using it
            new_reading = last_corrected_reading
            last_corrected_reading = Reading.by_register_id(register_id).sort('timestamp': -1).to_a[1]
          end
        end
        accounted_energy = Buzzn::AccountedEnergy.new(corrected_value, last_corrected_reading, new_reading, new_reading)
        accounted_energy.label = label
        return accounted_energy
      end

      # This method saves the new reading for a corrected register
      # input params:
      #   register_id: The Register::Base.id for which the reading should be saved
      #   corrected_value: the energy in milliwatt_hour that is used for the new reading
      #   timestamp: The timestamp for the new reading
      # returns:
      #   new_reading: The new Reading
      def save_corrected_reading(register_id, new_reading_value, timestamp)
        Reading.create!(register_id: register_id,
                        timestamp: timestamp,
                        energy_milliwatt_hour: new_reading_value,
                        reason: Reading::REGULAR_READING,
                        source: Reading::BUZZN_SYSTEMS,
                        quality: Reading::ENERGY_QUANTITY_SUMMARIZED,
                        meter_serialnumber: Register::Base.find(register_id).meter.product_serialnumber)
      end

      # This method returns the energy measured in a specific period of time
      # input params:
      #   register: The Register::Base for which the energy is requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   accounted_energy: Object, that contains all information about accounted readings and device changes
      def get_register_energy_for_period(register, begin_date, end_date, accounting_year=Time.current.year - 1)
        first_reading = get_first_reading(register, begin_date, accounting_year)
        last_reading_original = get_last_reading(register, end_date, accounting_year)
        last_reading = last_reading_original.clone
        device_change_readings = get_readings_at_device_change(register, begin_date, end_date, accounting_year)
        if end_date.nil?
          last_reading.timestamp = adjust_end_date(last_reading.timestamp, accounting_year)
          last_reading.energy_milliwatt_hour = adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        end
        if device_change_readings.empty?
          accounted_energy = last_reading.energy_milliwatt_hour - first_reading.energy_milliwatt_hour
          return Buzzn::AccountedEnergy.new(accounted_energy, first_reading, last_reading, last_reading_original)
        else
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          # if the device change happend exactly on the begin_date or end date just ignore it
          if (device_change_reading_1.timestamp == first_reading.timestamp && device_change_reading_2.timestamp != begin_date) ||
             (device_change_reading_2.timestamp == last_reading.timestamp && device_change_reading_1.timestamp != end_date)
            accounted_energy = last_reading.energy_milliwatt_hour - first_reading.energy_milliwatt_hour
            return Buzzn::AccountedEnergy.new(accounted_energy, first_reading, last_reading, last_reading_original)
          else
            accounted_energy = last_reading.energy_milliwatt_hour - device_change_reading_2.energy_milliwatt_hour + device_change_reading_1.energy_milliwatt_hour - first_reading.energy_milliwatt_hour
            return Buzzn::AccountedEnergy.new(accounted_energy, first_reading, last_reading, last_reading_original, true, device_change_reading_1, device_change_reading_2)
          end
        end
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
          # try to get the last reading one year before of the accounting_year (mostly at 31st December)
          first_reading_before = Reading.by_register_id(register.id)
                                  .in_year(accounting_year - 1)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .sort('timestamp': -1)
                                  .first

          # try to get the first reading in the accounting_year
          first_reading_behind = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .without_reason(Reading::DEVICE_CHANGE_1) # TODO: in the BK code is without device_change_2 but it seems wrong
                                  .sort('timestamp': 1)
                                  .first
          first_reading = select_closest_reading(Date.new(accounting_year, 1, 1), first_reading_before, first_reading_behind)
          # if no reading was found in the accounting year or one year before raise an error
          if first_reading.nil?
            raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the begin_date
          first_reading = Reading.by_register_id(register.id)
                                  .at(begin_date)
                                  .without_reason(Reading::DEVICE_CHANGE_1)
                                  .first
          # try to request the missing reading from data provider
          if first_reading.nil?
            first_reading = get_missing_reading(register, begin_date)
          end
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
          last_reading_before = Reading.by_register_id(register.id)
                                  .in_year(accounting_year)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .sort('timestamp': -1)
                                  .first
          last_reading = select_closest_reading(Date.new(accounting_year, 12, 31), last_reading_before, last_reading_behind)
          if last_reading.nil?
            raise ActiveRecord::RecordNotFound.new("no ending reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the end_date
          last_reading = Reading.by_register_id(register.id)
                                  .at(end_date)
                                  .without_reason(Reading::DEVICE_CHANGE_2)
                                  .first
          # try to request the missing reading from data provider
          if last_reading.nil?
            last_reading = get_missing_reading(register, end_date)
          end
          # if no reading was found at the specific date raise an error
          if last_reading.nil?
            raise ActiveRecord::RecordNotFound.new("no ending reading found for register #{register.id}")
          end
        end
        return last_reading
      end

      # This method returns one out of two readings, that is closest to a given date
      # input params:
      #   desired_date: The Date to which the readings are compared to
      #   reading_before: The reading, that is ahead (earlier) the other one
      #   reading_behind: The reading, that is behind (after) the other one
      # returns:
      #   reading: the reading, that is closer to the desired_date than the other one. If the distance is equal, reading_before is returned.
      def select_closest_reading(desired_date, reading_before, reading_behind)
        if reading_before.nil? && !reading_behind.nil?
          return reading_behind
        elsif !reading_before.nil? && reading_behind.nil?
          return reading_before
        elsif !reading_before.nil? && !reading_behind.nil?
          return (reading_before.timestamp.in_time_zone.to_date - desired_date).round.abs > (desired_date - reading_behind.timestamp.in_time_zone.to_date).round.abs ? reading_behind : reading_before
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
        when accounting_year - 1 # TODO: is this needed? And if so, is it correct?
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
        begin_date_query = begin_date || Time.new(accounting_year - 1, 12, 31, 23, 59, 59).utc
        end_date_query = end_date || Time.new(accounting_year, 12, 31, 23, 59, 59).utc
        device_change_readings = Reading.by_register_id(register.id)
                                .where(:timestamp.gt => begin_date_query)
                                .where(:timestamp.lt => end_date_query)
                                .by_reason(Reading::DEVICE_CHANGE_1, Reading::DEVICE_CHANGE_2)
                                .sort('reason': 1)
        return device_change_readings
      end

      # This method inter- or extrapolates the last_reading's energy value
      # input params:
      #   first_reading: The first reading that will be taken into account
      #   last_reading: The last reading the will be adjusted
      #   last_reading_original: The original last reading that would have been taken into account if its date would match
      #   device_change_readings: Array with 2 readings from a device_change. May be empty.
      # returns:
      #   last_reading.energy_milliwatt_hour: The adjusted energy value that has to be set to the last reading
      def adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        if device_change_readings.empty?
          # only adjust the reading if the timestamps differ

          if last_reading.timestamp != last_reading_original.timestamp
            timedifference_original = (last_reading.timestamp.in_time_zone.to_date - last_reading_original.timestamp.in_time_zone.to_date).round
            if timedifference_original != 0
              timespan = (last_reading_original.timestamp.in_time_zone.to_date - first_reading.timestamp.in_time_zone.to_date).round
              last_reading.energy_milliwatt_hour += timedifference_original * (last_reading.energy_milliwatt_hour - first_reading.energy_milliwatt_hour) * 1.0 / timespan

            end
          end
        else
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          # only adjust the reading if the timestamps differ
          if last_reading.timestamp != last_reading_original.timestamp
            timedifference_original = (last_reading.timestamp.in_time_zone.to_date - last_reading_original.timestamp.in_time_zone.to_date).round
            if timedifference_original != 0
              timespan = (last_reading_original.timestamp.in_time_zone.to_date - device_change_reading_2.timestamp.in_time_zone.to_date).round
              if device_change_reading_2.timestamp == last_reading_original.timestamp
                last_reading.energy_milliwatt_hour = timedifference_original * (device_change_reading_1.energy_milliwatt_hour - first_reading.energy_milliwatt_hour) * 1.0 / timespan + device_change_reading_2.energy_milliwatt_hour
              else
                last_reading.energy_milliwatt_hour += timedifference_original * (last_reading.energy_milliwatt_hour - device_change_reading_2.energy_milliwatt_hour) * 1.0 / timespan
              end
            end
          end
        end
        return last_reading.energy_milliwatt_hour
      end

      # This method gets missing readings from external services and stores them in DB
      # input params:
      #   register: The Register::Base for which the reading is requested
      #   date: The Date for which the reading is missing
      # returns:
      #   reading: The missing reading
      def get_missing_reading(register, date)
        unless register.meter.broker.is_a?(Broker::Discovergy)
          raise ArgumentError.new("register #{register.id} is not a discovergy register")
        end
        result = charts.for_register(register, Buzzn::Interval.second(date.beginning_of_day))
        if register.input?
          timestamp = result.in.first.timestamp
          value = result.in.first.value
        else
          timestamp = result.out.first.timestamp
          value = result.out.first.value
        end
        Reading.create!(register_id: register.id,
                        timestamp: timestamp,
                        energy_milliwatt_hour: value,
                        reason: Reading::REGULAR_READING,
                        source: Reading::BUZZN_SYSTEMS,
                        quality: Reading::READ_OUT,
                        state: 'Z86',
                        meter_serialnumber: register.meter.product_serialnumber)
      end

      # This method returns the timespan between two dates in months while considering half months
      # input params:
      #   date_1: The first Date to compare
      #   date_2: The second Date to compare
      # returns:
      #   months between two dates, e.g. 11 or 11.5 or 12
      def timespan_in_months(date_1, date_2)
        if date_1 > date_2
          date_2_temp = date_1.clone
          date_1 = date_2.clone
          date_2 = date_2_temp
        end
        days = date_2.day - date_1.day
        months = date_2.month - date_1.month
        years = date_2.year - date_1.year
        half_rounded = 0
        factor = days < 0 ? -1 : 1
        days = factor * days
        if days > 19
          half_rounded = factor * 1
        elsif days >= 9
          half_rounded = factor * 0.5
        end
        return years * 12 + months + half_rounded
      end
    end
  end
end
