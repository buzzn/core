class Beekeeper::Importer::GroupContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool, attributes)
    create_localpool_processing_contract(localpool, attributes[:start_date],
                                         attributes[:processing_contract_number],
                                         attributes[:processing_contract_number_addition])
    create_metering_point_operator_contract(localpool, attributes[:start_date],
                                         attributes[:metering_contract_number])
  end

  private

  def create_localpool_processing_contract(localpool, start_date, contract_number, contract_number_addition)
    attributes = {
      localpool: localpool,
      begin_date: start_date,
      signing_date: start_date,
      customer: localpool.owner,
      contractor: Organization::Market.buzzn,
      contract_number: contract_number,
      contract_number_addition: contract_number_addition
    }
    contract = Contract::LocalpoolProcessing.create!(attributes)
    logger.info("ProcessingContract create: #{contract.full_contract_number}")
  end

  def create_metering_point_operator_contract(localpool, start_date, contract_number)
    attributes = {
      localpool: localpool,
      begin_date: start_date,
      signing_date: start_date,
      customer: localpool.owner,
      contractor: Organization::Market.buzzn,
      contract_number: contract_number,
      contract_number_addition: 0
    }
    contract = Contract::MeteringPointOperator.create!(attributes)
    logger.info("MeteringPointOperator create: #{contract.full_contract_number}")
  end

end
