#
# Generate closed billings for contracts that have ended and have been billed in beekeeper.
# When we do _our_ billing, we need those so we know which energy consumption is already billed.
#
class Beekeeper::Importer::GenerateBillings

  attr_reader :logger

  LAST_BEEKEEPER_BILLING_CYCLE_YEAR = 2017

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool)
    begin_year = localpool.start_date.year
    # we assume all billing including 2017 has been done in beekeeper.
    end_year   = LAST_BEEKEEPER_BILLING_CYCLE_YEAR
    (begin_year..end_year).each do |year|
      billing_cycle = create_localpool_billing_cycle(localpool, year)
      create_annual_billings(localpool, billing_cycle)
    end
  end

  private

  def create_annual_billings(localpool, billing_cycle)
    localpool.market_locations.consumption.each do |market_location|
      contracts_to_bill(billing_cycle.date_range, market_location).each do |contract|
        create_billing(localpool, contract, billing_cycle)
      end
    end
  end

  def contracts_to_bill(date_range, market_location)
    market_location.contracts_in_date_range(date_range).where.not(type: 'Contract::LocalpoolThirdParty')
  end

  def create_billing(localpool, contract, billing_cycle)
    date_range = billing_date_range(contract, billing_cycle)
    attrs = {
      status: :closed, # closed means paid so we don't have to track payments/settling in our system any more.
      invoice_number: next_invoice_number(localpool),
      total_energy_consumption_kwh: 0,
      total_price_cents: 0,
      prepayments_cents: 0,
      receivables_cents: 0,
      contract: contract,
      billing_cycle: billing_cycle,
      bricks: [brick_for_contract(contract, date_range)],
      date_range: date_range
    }
    if Billing.create!(attrs)
      logger.info("Created billing for contract #{contract.id} (#{date_range})")
    end
  end

  def billing_date_range(contract, billing_cycle)
    begin_date = [billing_cycle.date_range.first, contract.begin_date].max
    end_date   = contract.end_date ? [billing_cycle.date_range.last, contract.end_date].min : billing_cycle.date_range.last
    begin_date...end_date
  end

  def brick_for_contract(contract, date_range)
    Billing::BrickBuilder.from_contract(contract, date_range)
  end

  def next_invoice_number(localpool)
    @@global_invoice_number ||= 0
    @@global_invoice_number += 1
    "BEE-#{format('%05d', @@global_invoice_number)}"
  end

  def create_localpool_billing_cycle(localpool, year)
    begin_date = (year == localpool.start_date.year) ? localpool.start_date : Date.new(year, 1, 1)
    end_date   = Date.new(year + 1, 1, 1)
    date_range = begin_date...end_date

    billing_cycle = BillingCycle.create!(
      localpool: localpool,
      date_range: date_range,
      name: date_range.first.year
    )

    if billing_cycle
      logger.debug("Created billing cycle #{billing_cycle.name}")
    end
    billing_cycle
  end

end
