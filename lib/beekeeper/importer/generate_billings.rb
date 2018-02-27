#
# Generate closed billings for contracts that have ended and have been billed in beekeeper.
# We need them so we know which is energy consumption is still unbilled when we do our billing.
#
class Beekeeper::Importer::GenerateBillings

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    localpool.market_locations.consumption.each do |ml|
      ended_contracts = ml.contracts.to_a.select { |c| c.status.ended? }
      ended_contracts.each do |contract|
        attrs = {
          status: :closed,
          begin_date: contract.begin_date,
          end_date: contract.end_date,
          total_energy_consumption_kwh: 0,
          total_price_cents: 0,
          prepayments_cents: 0,
          receivables_cents: 0,
          localpool_power_taker_contract_id: contract.id
        }
        if Billing.create!(attrs)
          logger.info("Created billing for ended contract #{contract.id} (#{contract.begin_date}..#{contract.end_date})")
        end
      end
    end
  end

end
