#
# Generate closed billings for contracts that have ended and have been billed in beekeeper.
# When we do _our_ billing, we need those so we know which energy consumption is already billed.
#
class Beekeeper::Importer::GenerateBillings

  attr_reader :logger

  MAX_DATE_RANGE = Date.new(2000, 1, 1)..Date.new(2020, 1, 1)
  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    localpool.market_locations.consumption.each.with_index(1) do |ml, index|
      ended_contracts = ml.contracts.to_a.select { |c| c.status.ended? }
      ended_contracts.each do |contract|
        attrs = {
          status: :closed,
          invoice_number: "BK-IMPORT-LP#{localpool.id}-#{index}",
          begin_date: contract.begin_date,
          end_date: contract.end_date,
          total_energy_consumption_kwh: 0,
          total_price_cents: 0,
          prepayments_cents: 0,
          receivables_cents: 0,
          localpool_power_taker_contract_id: contract.id,
          bricks: [brick_for_contract(contract)]
        }
        if Billing.create!(attrs)
          logger.info("Created billing for ended contract #{contract.id} (#{contract.begin_date}..#{contract.end_date})")
        end
      end
    end
  end

  def brick_for_contract(contract)
    Billing::BrickBuilder.from_contract(contract, MAX_DATE_RANGE)
  end

end
