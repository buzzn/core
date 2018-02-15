class Beekeeper::Importer::SetLocalpoolGapContractCustomer

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    customer = Beekeeper::Importer::GapContractCustomer.find_by_localpool(localpool)
    if customer
      localpool.update_attributes(gap_contract_customer: customer)
    else
      logger.warn('No gap contract customer found.')
    end
  end

end
