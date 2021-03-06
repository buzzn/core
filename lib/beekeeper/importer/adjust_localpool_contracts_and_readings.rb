# Iterate all the group's registers and fix up contracts so that
# - every register has a time-gap-free list of contracts
# - every powertaker contract has a reading for begin- and end date.
#
class Beekeeper::Importer::AdjustLocalpoolContractsAndReadings

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(localpool)
    localpool.registers.each do |register|
      logger.debug("Meter: #{register.meter.legacy_buzznid}")
      contract_pairs(register).each do |contract, next_contract, gap_in_days|
        case gap_in_days
        when 0
          # contracts are already continuous --> nothing to do here
          comment = nil
        when 1
          adjust_end_date_and_readings(contract, register)
          comment = '1 day gap fixed by moving old end date one day ahead'
        end
        comment = " (#{comment})" if comment
        logger.info("Contract #{contract.contract_number}/#{contract.contract_number_addition}: #{contract.end_date} - #{next_contract.begin_date}#{comment}")
      end
    end
    # Fix / add a few readings
    if ['fritz-winter-strasse', 'gertrud-grunow-strasse', 'woge', 'tassiloweg'].include?(localpool.slug)
      localpool.register_metas.uniq.to_a.keep_if {|x| x.label.consumption?}.each do |register_meta|
        date = Date.new(2015, 12, 31)
        register_meta.registers.each do |r|
          next unless r.readings.before(date).any? && r.readings.after(date).any? && r.readings.where(:date => date).empty?
          value = r.readings.before(date).order(:date).last.value
          reading = r.readings.create!(date: date,
                                       raw_value: value,
                                       reason: :regular_reading,
                                       comment: 'Import 2019',
                                       read_by: :buzzn,
                                       status: :z86,
                                       source: :manual,
                                       quality: :read_out)
          logger.info("Created fake reading for #{r.meter.attributes}", extra_data: reading.attributes)
        end
      end
    end
  end

  private

  def adjust_end_date_and_readings(contract, register)
    ActiveRecord::Base.transaction do
      old_end_date = contract.end_date
      contract.update_attribute(:end_date, contract.end_date + 1.day)
      adjust_readings(contract.register_meta.registers, old_end_date)
    end

  end

  # Returns pairs of contracts that chronologically follow each other.
  # This data structure simplifies the iteration and fixing/creation of contracts.
  def contract_pairs(register)
    ordered_contracts = register.meta.contracts.order(begin_date: :asc).to_a
    ordered_contracts[0...-1].map.with_index do |contract, index|
      next_contract = ordered_contracts[index + 1]
      if contract.end_date.nil?
        raise("contract #{contract.contract_number}/#{contract.contract_number_addition} needs to be terminated")
      end
      gap_in_days = (next_contract.begin_date - contract.end_date).to_i
      [contract, next_contract, gap_in_days]
    end
  end

  # By default, we expect a register in beekeeper to have one or two readings when contracts change.
  # The registers listed here have more than that, but we still allow that, because those readings are unrelated
  # to the contract change.
  REGISTERS_WITH_IGNORED_MULTIPLE_READINGS = %w(90031/27 90053/44 90075/10)

  # In beekeeper, readings for contract changes aren't consistent. Sometimes there's only one for the old contract's
  # end date, sometimes only one for new contract's start date, sometimes there are both.
  # This method cleans things up so that only one reading for the date of the contract change remains.
  def adjust_readings(registers, old_end_date)
    registers.each do |register|
      readings = register.readings.where(date: [old_end_date, old_end_date + 1.day]).order(:date)
      case readings.size
      when 2
        return handle_two_readings(readings, register)
      when 1
        return handle_one_reading(readings.first, old_end_date)
      else
        next
      end
    end
    unless REGISTERS_WITH_IGNORED_MULTIPLE_READINGS.include?(registers.first.meter.legacy_buzznid)
      logger.error(
        "Expected two readings on #{registers.first.meter.legacy_buzznid} but got something else. See extra_data for details.",
        extra_data: {
          old_end_date: old_end_date
        }
      )
    end
  end

  def next_contract_number_addition(localpool)
    current_max = localpool.contracts.for_localpool.maximum(:contract_number_addition)
    current_max + 1
  end

  def find_gap_contract_customer(localpool)
    customer = Beekeeper::Importer::GapContractCustomer.find_by_localpool(localpool)
    customer ? customer : logger.error('No customer for gap contract found!')
  end

  def handle_two_readings(readings, register)
    if readings.first.raw_value == readings.last.raw_value
      readings.first.delete
      logger.info("Destroyed reading for #{readings.first.date} since both readings have the same value.")
    else
      logger.info(
        'Readings for old contract end and new contract start have different values, this is resolved in code. See extra_data for reading details.',
        extra_data: readings.collect { |r| r.inspect }
      )
      case register.meter.legacy_buzznid
      when '90057/7'
        # 2nd reading has a slightly higher reading than the first one one. Just delete the first one.
        readings.first.delete
      when '90067/18'
        readings.first.delete # this one has a value of 13.000
        # this one has 12.700 -- must be a bug/manual entry error, technically it's not possible for a reading to go down
        readings.last.update_column(:raw_value, 13_000)
      when '90067/6'
        # [INFO] Readings: date: 2018-01-14, 2122400.0, contract_change // date: 2018-01-15, 2132100.0, contract_change
        # 2nd reading has a slightly higher reading than the first one. Just delete the first one.
        readings.first.delete
      else
        byebug.byebug
        logger.warn("Unexpected duplicate readings for #{register.meter.legacy_buzznid}. Please add code to decide on which reading to keep.")
      end
    end
  end

  def handle_one_reading(reading, old_end_date)
    if reading.date == old_end_date
      # shift reading date ahead one day to match the new contract end date
      reading.update_column(:date, reading.date + 1.day)
    else
      # case: the only reading is on the new contract end date -- that's what we want, nothing to do.
    end
  end

end
