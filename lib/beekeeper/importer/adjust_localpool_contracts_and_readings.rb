# Iterate all the group's registers and fix up contracts so that
# - every register has a time-gap-free list of contracts
# - every powertaker contract has a reading for begin- and end date.
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
    ordered_contracts = register.contracts.order(begin_date: :asc).to_a
    ordered_contracts[0...-1].map.with_index do |contract, index|
      next_contract = ordered_contracts[index + 1]
      gap_in_days   = (next_contract.begin_date - contract.end_date).to_i
      [contract, next_contract, gap_in_days]
    end
  end

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
      # In the beekeeper dump 2018-01-25 there's one case with 0 readings, but that contract ended on 2018-02-01
      #  so natually there's no reading yet. Nothing to do for that one.
      logger.error("Expected two readings but got #{readings.size}: #{readings.inspect}")
    end
  end

  def create_gap_contract(previous_contract, next_contract)
    attributes = {
      # take these from previous contract
      localpool:                     previous_contract.localpool,
      register:                      previous_contract.register,
      signing_date:                  previous_contract.end_date,
      begin_date:                    previous_contract.end_date,
      contractor:                    previous_contract.localpool.owner,
      contract_number:               previous_contract.contract_number,
      # take these from next contract
      termination_date:              next_contract.begin_date,
      end_date:                      next_contract.begin_date,
      # these attributes come from different places ...
      contract_number_addition:      next_contract_number_addition(previous_contract.localpool),
      customer:                      find_contract_customer(previous_contract.localpool)
    }
    Contract::LocalpoolGap.create!(attributes)
  end

  def next_contract_number_addition(localpool)
    current_max = localpool.localpool_power_taker_contracts.maximum(:contract_number_addition)
    current_max + 1
  end

  GAP_CONTRACT_CUSTOMER_LOOKUP = {
    # localpool slug => contract number which has the customer to be used
    'cherubinistr'                      => '60009/8',
    'gertrud-grunow-strasse'            => '60030/37',
    'gotthardstrasse'                   => '60010/1',
    'hofackerstrasse'                   => '60006/3',
    'mehrgenerationenplatz-forstenried' => '60015/73',
    'wachsbleiche'                      => '60014/12',
    'wagnis'                            => '60008/52',
    'scheffelstrasse'                   => '60044/7'
  }

  def find_contract_customer(localpool)
    buzznid = GAP_CONTRACT_CUSTOMER_LOOKUP[localpool.slug]
    unless buzznid
      logger.error("Customer for localpool '#{localpool.name}' gap contract isn't set, not creating one.")
      return
    end
    contract_number, contract_number_addition = buzznid.split('/')
    contract = Contract::LocalpoolPowerTaker.find_by(contract_number: contract_number, contract_number_addition: contract_number_addition)
    contract.customer
  end

  def handle_two_readings(readings, register)
    if readings.first.value == readings.last.value
      readings.first.destroy!
      logger.info("Destroyed reading for #{readings.first.date} since both readings have the same value.")
    else
      logger.info('Readings for old contract end and new contract start have different values, this is resolved in code')
      logger.info('Readings: ' + readings.collect { |r| "date: #{r.date}, #{r.value}" }.join(' // ') )
      if register.meter.legacy_buzznid == '90057/7'
        # in this case the 2nd reading has a slightly higher reading than the first one one. Just delete the first one.
        readings.first.destroy!
      elsif register.meter.legacy_buzznid == '90067/18'
        readings.first.destroy! # this one has a value of 13.000
        # this one has 12.700 -- must be a bug/manual entry error, technically it's not possible for a reading to go down
        readings.last.update_attribute(:value, 13_000)
      else
        logger.error("Unexpected readings for #{register.meter.legacy_buzznid}, not modifying any readings.")
      end
    end
  end

  def handle_one_reading(reading, old_end_date)
    if reading.date == old_end_date
      # shift reading date ahead one day to match the new contract end date
      reading.update_attribute(:date, reading.date + 1.day)
    else
      # case: the only reading is on the new contract end date -- that's what we want, nothing to do.
    end
  end

end
