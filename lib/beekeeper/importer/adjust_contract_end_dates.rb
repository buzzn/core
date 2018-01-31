# Iterate all the group's registers and change the end data of each contract as specified in
# https://github.com/buzzn/scrum/issues/142.
# This is done to obtain a time-gap-free list of contracts for each register.
class Beekeeper::Importer::AdjustContractEndDates

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    localpool.registers.each do |register|
      logger.debug "* Meter: #{register.meter.legacy_buzznid}"
      ordered_contracts = register.contracts.order(begin_date: :asc).to_a
      ordered_contracts.each.with_index do |contract, index|
        next_contract = ordered_contracts[index + 1]
        if must_fix_contract?(contract, next_contract)
          old_end_date = contract.end_date
          contract.update_attribute(:end_date, contract.end_date + 1.day)
          fix_label = " (adjusted from #{old_end_date} to fix gap)"
        else
          ""
        end
        logger.debug("#{index + 1}. #{contract.contract_number}/#{contract.contract_number_addition}: #{contract.begin_date} - #{contract.end_date}#{fix_label}")
      end
    end
  end

  private

  def must_fix_contract?(current_contract, next_contract)
    return false unless next_contract
    current_contract.end_date == (next_contract.begin_date - 1.day)
  end
end
