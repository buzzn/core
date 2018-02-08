# Iterate all the group's registers and fix up contracts so there's
#
# - a time-gap-free list of contracts for every register.
# - a reading for every contract begin- and end date.
#
class Beekeeper::Importer::AdjustLocalpoolContractsAndReadings

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    localpool.registers.each do |register|
      logger.debug("* Meter: #{register.meter.legacy_buzznid}")
      contract_pairs(register).each do |contract, next_contract, gap_in_days|
        case gap_in_days
        when 0
          # data is 0 clean, nothing to do here
          comment = nil
        when 1
          # move end date of contract one day ahead for the dates to match
          adjust_end_date_and_readings(contract, register)
          comment = "1 day gap fixed by moving old end date one day ahead"
        else
          create_gap_contract(contract, next_contract)
          comment = "gap of #{gap_in_days} days filled with a 'Leerstandsvertrag' (gap contract)"
        end
        comment = " (#{comment})" if comment
        logger.info("Contract #{contract.contract_number}/#{contract.contract_number_addition}: #{contract.begin_date} - #{contract.end_date}#{comment}")
      end
    end
  end

  private

  def adjust_end_date_and_readings(contract, register)
    ActiveRecord::Base.transaction do
      contract.update_attribute(:end_date, contract.end_date + 1.day)
      adjust_readings(register, contract.end_date)
    end

  end

  # Returns pairs of contracts that follow each other.
  # This data structure simplifies the following iteration and fixing/creation of contracts.
  def contract_pairs(register)
    ordered_contracts = register.contracts.order(begin_date: :asc).to_a
    ordered_contracts[0...-1].map.with_index do |contract, index|
      next_contract = ordered_contracts[index + 1]
      gap = gap_in_days(contract, next_contract)
      [contract, next_contract, gap]
    end
  end

  def gap_in_days(current_contract, next_contract)
    (next_contract.begin_date - current_contract.end_date).to_i
  end

  def adjust_readings(register, old_end_date)
    readings = register.readings.where(date: [old_end_date, old_end_date + 1.day]).order(:date)
    case readings.size
    when 2
      handle_two_readings(readings, register)
    when 1
      handle_one_reading(readings.first, old_end_date)
    else
      # In the beekeeper dump 2018-01-25 there's one case with 0 readings, but that contract ended on 2018-02-01
      #  so natually there's no reading yet. Nothing to do for that one.
      logger.error("Expected two readings but got #{readings.size}: #{readings.inspect}")
    end
  end

  def create_gap_contract(previous_contract, next_contract)
    owner = previous_contract.localpool.owner
    attributes = {
      localpool:                     previous_contract.localpool,
      register:                      previous_contract.register,
      signing_date:                  previous_contract.end_date,
      begin_date:                    previous_contract.end_date,
      termination_date:              next_contract.begin_date,
      end_date:                      next_contract.begin_date,
      contract_number:               previous_contract.contract_number,
      contract_number_addition:      next_contract_number_addition(previous_contract.localpool),
      customer:                      owner,
      contractor:                    owner,
      # CLARIFY need to set?
      # customer_bank_account,
      # contractor_bank_account,
      # CLARIFY if this needs special treatment
      # renewable_energy_law_taxation,
      # CLARIFY if this attribute is still needed
      # metering_point_operator_name,
    }
    Contract::LocalpoolPowerTaker.create!(attributes)
  end

  def next_contract_number_addition(localpool)
    current_max = localpool.localpool_power_taker_contracts.maximum(:contract_number_addition)
    current_max + 1
  end

  def handle_two_readings(readings, register)
    if readings.first.value == readings.last.value
      readings.first.destroy!
      logger.info("Destroyed reading for #{readings.first.date} since both readings have the same value.")
    else
      logger.info("Readings for old contract end and new contract start have different values, this is resolved in code")
      logger.info("Readings: " + readings.map { |r| "date: #{r.date}, #{r.value}" }.join(' // ') )
      if register.meter.legacy_buzznid == "90057/7"
        # in this case the 2nd reading has a slightly higher reading than the first one one. Just delete the first one.
        readings.first.destroy!
      elsif register.meter.legacy_buzznid == "90067/18"
        readings.first.destroy! # this one has a value of 13.000
        # this one has 12.700 -- must be a bug/manual entry error, technically it's not possible for a reading to go down
        readings.last.update_attribute(:value, 13_000)
      else
        logger.error("Unexpected readings for register.meter.legacy_buzznid, not modifying any readings.")
      end
    end
  end

  def handle_one_reading(reading, old_end_date)
    # the cases are 90002/14, 90017/8 and 90043/3
    if reading.date == old_end_date
      # shift reading date ahead one day to match the new contract end date
      reading.update_attribute(:date, reading.date + 1.day)
    else
      # case: the only reading is on the new contract end date -- that's what we want, nothing to do.
    end
  end
end
