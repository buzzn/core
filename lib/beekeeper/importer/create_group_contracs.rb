class Beekeeper::Importer::GroupContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    @logger.section = 'create-group-contracts'
  end

  def run(localpool, attributes)
    create_localpool_processing_contract(localpool, attributes[:start_date], attributes[:processing_contract_number], attributes[:processing_contract_number_addition])
    create_metering_point_operator_contract(localpool, attributes[:start_date], attributes[:metering_contract_number])
  end

  private

  def create_localpool_processing_contract(localpool, start_date, contract_number, contract_number_addition)
    begin
      konto = Beekeeper::Minipool::Kontodaten.where(vertragsnummer: contract_number, nummernzusatz: 0).first
    rescue Buzzn::RecordNotFound => e
      logger.error("Couldn't create bank account #{konto.attributes} for #{contract_number}/#{contract_number_addition}", extra_data: e.message)
    end
    tax_data_attrs = {}.tap do |h|

      if konto
        if konto.steuernummer && konto.steuernummer.size.positive?
          h[:tax_number] = konto.steuernummer
        end
        if konto.ust_id && konto.ust_id.size.positive?
          h[:sales_tax_number] = konto.ust_id
        end
        h[:creditor_identification] = konto.sepa_attrs[:creditor_identification]
      end
    end

    attributes = {
      localpool: localpool,
      begin_date: start_date,
      signing_date: start_date,
      customer: localpool.owner,
      contractor: Organization::Market.buzzn,
      contract_number: contract_number,
      contract_number_addition: contract_number_addition,
      tax_data: Contract::TaxData.new(tax_data_attrs),
    }.tap do |h|
      if konto
        h[:mandate_reference] = konto.sepa_attrs[:mandate_reference]
      end
    end
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
