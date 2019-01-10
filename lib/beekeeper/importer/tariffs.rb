class Beekeeper::Importer::Tariffs

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(localpool, tariffs)
    tariffs.collect do |attributes|
      attributes.delete(:end_date)
      tariff = Contract::Tariff.new(attributes)
      tariff.group = localpool
      unless tariff.save
        logger.error("Failed to save tariff #{tariff.inspect}")
        logger.error("Errors: #{tariff.errors.inspect}")
      end
      # also add tariff to localpool
      localpool.gap_contract_tariffs << tariff
      tariff
    end
  end

end
