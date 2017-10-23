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
        register_grid_consumption_corrected = nil
        register_grid_feeding_corrected = nil

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
            register_grid_consumption_corrected = register
          elsif register.grid_feeding_corrected?
            register_grid_feeding_corrected = register
          else
            accounted_energy = get_register_energy_for_period(register, begin_date, end_date, accounting_year)
            accounted_energy.label = accounted_energy.first_reading.register.label
            result.add(accounted_energy)
          end
        end
        grid_consumption_corrected, grid_feeding_corrected = calculate_corrected_grid_values(result, register_grid_consumption_corrected, register_grid_feeding_corrected)
        result.add(grid_consumption_corrected)
        result.add(grid_feeding_corrected)
        result
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
            if contract.full?
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
      def calculate_corrected_grid_values(total_accounted_energy, register_grid_consumption_corrected, register_grid_feeding_corrected)
        consumption_third_party = total_accounted_energy.sum(Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY)
        grid_consumption = total_accounted_energy[Buzzn::AccountedEnergy::GRID_CONSUMPTION].value
        grid_consumption_corrected =
          if grid_consumption - consumption_third_party > Buzzn::Utils::Energy.zero
            grid_consumption - consumption_third_party
          else
            Buzzn::Utils::Energy.zero
          end
        grid_consumption_corrected_result =
          create_corrected_reading(register_grid_consumption_corrected,
                                   Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED,
                                   grid_consumption_corrected,
                                   total_accounted_energy[Buzzn::AccountedEnergy::GRID_CONSUMPTION].last_reading.date)
        grid_feeding_corrected =
          if grid_consumption - consumption_third_party > Buzzn::Utils::Energy::ZERO
            total_accounted_energy[Buzzn::AccountedEnergy::GRID_FEEDING].value
          else
            total_accounted_energy[Buzzn::AccountedEnergy::GRID_FEEDING].value - grid_consumption + consumption_third_party
          end
        grid_feeding_corrected_result = create_corrected_reading(register_grid_feeding_corrected, Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED, grid_feeding_corrected, total_accounted_energy[Buzzn::AccountedEnergy::GRID_FEEDING].last_reading.date)
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
      def create_corrected_reading(register, label, corrected_value, date)
        # TODO: (nice-to-have) validate that all corrected registers must have an initial reading with energy_milliwatt_hour = 0
        last_corrected_reading = register.readings.order(:date).last
        if last_corrected_reading.nil?
          new_reading = save_corrected_reading(register, corrected_value, date)
        else
          if last_corrected_reading.date != date
            new_reading = save_corrected_reading(register, corrected_value + last_corrected_reading.corrected_value, date)
          else
            # TODO: maybe think about overwriting an existing reading instead of using it
            new_reading = last_corrected_reading
            last_corrected_reading = register.readings.order(:date)[-2]
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
      def save_corrected_reading(register, value, date)
        register.readings.create(date: date,
                                 raw_value: value.value,
                                 corrected_value: value,
                                 reason: Reading::Single::REGULAR_READING,
                                 # TODO need an internal ID for such cases
                                 source: Reading::Single::MANUAL,
                                 read_by: Reading::Single::BUZZN,
                                 quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED)
      end

      # This method returns the energy measured in a specific period of time
      # input params:
      #   register: The Register::Base for which the energy is requested
      #   begin_date: The Date of the period's beginning. Can be nil if the beginning is not definite.
      #   end_date: The Date of the period's ending. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   accounted_energy: Object, that contains all information about accounted readings and device changes
      def get_register_energy_for_period(register, begin_date, end_date, accounting_year = Date.year - 1)
        first_reading = get_first_reading(register, begin_date, accounting_year)
        last_reading_original = get_last_reading(register, end_date, accounting_year)
        last_reading = Reading::Single.new(last_reading_original.attributes)
        device_change_readings = get_readings_at_device_change(register, begin_date, end_date, accounting_year)
        if end_date.nil?
          last_reading.date = adjust_end_date(last_reading.date, accounting_year)
          last_reading.corrected_value = adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        end
        if device_change_readings.empty?
          accounted_energy = last_reading.corrected_value - first_reading.corrected_value
          return Buzzn::AccountedEnergy.new(accounted_energy, first_reading, last_reading, last_reading_original)
        else
          #binding.pry
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          # if the device change happend exactly on the begin_date or end date just ignore it
          if (device_change_reading_1.date == first_reading.date && device_change_reading_2.date != begin_date) ||
             (device_change_reading_2.date == last_reading.date && device_change_reading_1.date != end_date)
            accounted_energy = last_reading.corrected_value - first_reading.corrected_value
            return Buzzn::AccountedEnergy.new(accounted_energy, first_reading, last_reading, last_reading_original)
          else
            #binding.pry
            accounted_energy = last_reading.corrected_value - device_change_reading_2.corrected_value + device_change_reading_1.corrected_value - first_reading.corrected_value
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
          first_reading_before = register.readings
                                  .in_year(accounting_year - 1)
                                  .without_reason(Reading::Single::DEVICE_CHANGE_1)
                                  .order(:date)
                                  .last

          # try to get the first reading in the accounting_year
          first_reading_behind = register.readings
                                   .in_year(accounting_year)
                                   .without_reason(Reading::Single::DEVICE_CHANGE_1) # TODO: in the BK code is without device_change_2 but it seems wrong
                                   .order(:date)
                                   .first
          first_reading = select_closest_reading(Date.new(accounting_year, 1, 1), first_reading_before, first_reading_behind)
          # if no reading was found in the accounting year or one year before raise an error
          if first_reading.nil?
            raise RecordNotFoundError.new("no beginning reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the begin_date
          first_reading = register.readings
                            .where(date: begin_date)
                            .without_reason(Reading::Single::DEVICE_CHANGE_1)
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
          last_reading_behind = register.readings
                                  .in_year(accounting_year + 1)
                                  .without_reason(Reading::Single::DEVICE_CHANGE_2)
                                  .order(:date)
                                  .first

          # try to get the last reading in the accounting_year
          last_reading_before = register.readings
                                  .in_year(accounting_year)
                                  .without_reason(Reading::Single::DEVICE_CHANGE_2)
                                  .order(:date)
                                  .last
          last_reading = select_closest_reading(Date.new(accounting_year, 12, 31), last_reading_before, last_reading_behind)
          if last_reading.nil?
            raise ActiveRecord::RecordNotFound.new("no ending reading found for register #{register.id}")
          end
        else
          # try to get the the reading exactly at the end_date
          last_reading = register.readings
                                 .where(date: end_date)
                                 .without_reason(Reading::Single::DEVICE_CHANGE_2)
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
        if reading_before && reading_behind
          if (reading_before.date  - desired_date).abs > (desired_date - reading_behind.date).abs
            reading_behind
          else
            reading_before
          end
        else
          reading_before || reading_behind
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
          Date.new(end_date.year - 1, 12, 31)
        when accounting_year
          Date.new(end_date.year, 12, 31)
        when accounting_year - 1 # TODO: is this needed? And if so, is it correct?
          Date.new(end_date.year - 2, 12, 31)
        else
          raise ArgumentError.new("unable to adjust the end_date #{end_date}.")
        end
      end

      # This method returns a Time at the end of the year in a desired year
      # input params:
      #   end_date: The Date of the period's ending that has to be adjusted. Can be nil if the ending is not definite.
      #   accounting_year: The year for which the energy should be accounted to
      # returns:
      #   time: the adjusted time
      def adjust_end_date2(end_date, accounting_year)
        if end_date.year < accounting_year
          raise ArgumentError.new("unable to adjust the end_date #{end_date}.")
        end
        Date.new(accounting_year + 1, 1, 1)
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
        register.readings
          .between(begin_date || Date.new(accounting_year),
                   end_date || Date.new(accounting_year + 1))
          .with_reason(Reading::Single::DEVICE_CHANGE_1,
                       Reading::Single::DEVICE_CHANGE_2)
          .order(:reason)
      end

      # This method inter- or extrapolates the last_reading's energy value
      # input params:
      #   first_reading: The first reading that will be taken into account
      #   last_reading: The last reading that will be adjusted
      #   last_reading_original: The original last reading that would have been taken into account if its date would match
      #   device_change_readings: Array with 2 readings from a device_change. May be empty.
      # returns:
      #   The adjusted energy value
      def adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        last = last_reading.corrected_value
        # only adjust the reading if the timestamps differ
        return last if last_reading.date == last_reading_original.date
        diff_original = last_reading.date - last_reading_original.date
        if device_change_readings.empty?
          timespan = last_reading_original.date - first_reading.date
          last + (last - first_reading.corrected_value) * diff_original / timespan
        else
          device_change_reading_1 = device_change_readings.first
          device_change_reading_2 = device_change_readings.last
          if device_change_reading_2.date == last_reading_original.date
            timespan = last_reading_original.date - device_change_reading_1.date
            (device_change_reading_1.corrected_value - first_reading.corrected_value) * diff_original / timespan + device_change_reading_2.corrected_value
          else
            timespan = last_reading_original.date - device_change_reading_2.date
            last + (last - device_change_reading_2.corrected_value) * diff_original / timespan
          end
        end
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
        register.readings.create!(timestamp: timestamp,
                                  value: value * 1000,
                                  unit: :watt_hour,
                                  reason: Reading::Single::REGULAR_READING,
                                  source: Reading::Single::BUZZN_SYSTEMS,
                                  quality: Reading::Single::READ_OUT,
                                  state: Reading::Single::Z86)
      end
    end
  end
end
