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
        else
          create_gap_contract(contract, next_contract)
          comment = "gap of #{gap_in_days} days filled with a 'Leerstandsvertrag' (gap contract)"
        end
        comment = " (#{comment})" if comment
        logger.info("Contract #{contract.contract_number}/#{contract.contract_number_addition}: #{contract.end_date} - #{next_contract.begin_date}#{comment}")
      end
    end
  end

  private

  def adjust_end_date_and_readings(contract, register)
    ActiveRecord::Base.transaction do
      old_end_date = contract.end_date
      contract.update_attribute(:end_date, contract.end_date + 1.day)
      adjust_readings(register, old_end_date)
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
  def adjust_readings(register, old_end_date)
    readings = register.readings.where(date: [old_end_date, old_end_date + 1.day]).order(:date)
    case readings.size
    when 2
      handle_two_readings(readings, register)
    when 1
      handle_one_reading(readings.first, old_end_date)
    else
      unless REGISTERS_WITH_IGNORED_MULTIPLE_READINGS.include?(register.meter.legacy_buzznid)
        logger.error(
          "Expected two readings on #{register.meter.legacy_buzznid} but got #{readings.size}. See extra_data for details.",
          extra_data: readings.map { |r| inspect_reading(r) }
        )
      end
    end
  end

  def create_gap_contract(previous_contract, next_contract)
    attributes = {
      # take these from previous contract
      localpool:                     previous_contract.localpool,
      register_meta:                 previous_contract.register_meta,
      signing_date:                  previous_contract.end_date,
      begin_date:                    previous_contract.end_date,
      contractor:                    previous_contract.localpool.owner,
      contract_number:               previous_contract.contract_number,
      # take these from next contract
      termination_date:              next_contract.begin_date,
      end_date:                      next_contract.begin_date,
      # these attributes come from different places ...
      contract_number_addition:      next_contract_number_addition(previous_contract.localpool),
      customer:                      find_gap_contract_customer(previous_contract.localpool),
      tariffs:                       previous_contract.localpool.gap_contract_tariffs
    }
    Contract::LocalpoolGap.create!(attributes)
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
    if readings.first.value == readings.last.value
      readings.first.delete
      logger.info("Destroyed reading for #{readings.first.date} since both readings have the same value.")
    else
      logger.info(
        'Readings for old contract end and new contract start have different values, this is resolved in code. See extra_data for reading details.',
        extra_data: readings.collect { |r| inspect_reading(r) }
      )
      case register.meter.legacy_buzznid
      when '90057/7'
        # 2nd reading has a slightly higher reading than the first one one. Just delete the first one.
        readings.first.delete
      when '90067/18'
        readings.first.delete # this one has a value of 13.000
        # this one has 12.700 -- must be a bug/manual entry error, technically it's not possible for a reading to go down
        readings.last.update_column(:value, 13_000)
      when '90067/6'
        # [INFO] Readings: date: 2018-01-14, 2122400.0, contract_change // date: 2018-01-15, 2132100.0, contract_change
        # 2nd reading has a slightly higher reading than the first one. Just delete the first one.
        readings.first.delete
      else
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

  def inspect_reading(reading)
    reading.attributes.slice('date', 'value', 'reason', 'comment', 'id')
  end

end
