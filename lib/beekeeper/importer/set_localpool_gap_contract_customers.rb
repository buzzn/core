class Beekeeper::Importer::SetLocalpoolGapContractCustomer

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    customer = Beekeeper::Importer::GapContractCustomer.find_by_localpool(localpool)
    localpool.update_attributes(gap_contract_customer: customer) if customer
  end

end
