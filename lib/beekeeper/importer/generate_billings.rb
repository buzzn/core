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
    # First, create the billing cycles with their different ranges (initial, yearly and final).
    # That way the following code can be written (almost) without special cases.
    billing_cycles = create_billing_cycles(localpool)
    # then run them
    billing_cycles.each do |billing_cycle|
      created_billings = create_billings(localpool, billing_cycle)
      billing_cycle.destroy! if created_billings.size.zero? # quick and dirty
    end
    create_billings_for_current_year(localpool)
  end

  private

  def create_billing_cycles(localpool)
    return [] if localpool.start_date.year == Date.today.year # nothing to do for those
    date_ranges = []
    # range for localpool start year
    date_ranges << (localpool.start_date...Date.new(localpool.start_date.year + 1, 1, 1))
    # yearly ranges since then
    ((localpool.start_date.year + 1)..LAST_BEEKEEPER_BILLING_CYCLE_YEAR).each do |year|
      date_ranges << (Date.new(year, 1, 1)...Date.new(year + 1, 1, 1))
    end
    date_ranges.map { |date_range| create_billing_cycle(localpool, date_range) }
  end

  def create_billing_cycle(localpool, date_range)
    name = range_spans_one_year?(date_range) ? date_range.first.year : "#{date_range.first} - #{date_range.last}"
    logger.info("Creating billing cycle #{name}")
    BillingCycle.create!(localpool: localpool, date_range: date_range, name: name)
  end

  def range_spans_one_year?(date_range)
    ((date_range.first.year + 1) == date_range.last.year) &&
      [date_range.first.month, date_range.first.day, date_range.last.month, date_range.last.day].all? { |nr| nr == 1 }
  end

  def create_billings(localpool, billing_cycle)
    billings = []
    localpool.market_locations.consumption.each do |market_location|
      contracts_to_bill(market_location, billing_cycle.date_range).each do |contract|
        date_range = billing_date_range(contract, billing_cycle)
        billings << create_billing(localpool, contract, date_range, billing_cycle)
      end
    end
    billings.flatten
  end

  def contracts_to_bill(market_location, date_range)
    #market_location.contracts_in_date_range(date_range).without_third_party
    # FIXME: create fake billings for third party contracts; right now that's the only way to show them on the the billing cycle page
    market_location.contracts_in_date_range(date_range)
  end

  def create_billing(localpool, contract, date_range, billing_cycle = nil)
    Billing.create!(
      status: :closed, # closed means paid so we don't have to track payments/settling in our system any more.
      invoice_number: next_invoice_number,
      contract: contract,
      billing_cycle: billing_cycle,
      items: [item_for_contract(contract, date_range)],
      date_range: date_range
    )
    logger.debug("Created billing for contract #{contract.id} (#{date_range})")
  end

  def billing_date_range(contract, billing_cycle)
    begin_date = [billing_cycle.date_range.first, contract.begin_date].max
    end_date   = contract.end_date ? [billing_cycle.date_range.last, contract.end_date].min : billing_cycle.date_range.last
    begin_date...end_date
  end

  def item_for_contract(contract, date_range)
    item = Builders::Billing::ItemBuilder.from_contract(contract, date_range)
    # TODO make contract.register
    item.register = contract.market_location.register
    item
  end

  # rubocop:disable Style/ClassVars
  def next_invoice_number
    @@global_invoice_number ||= 0
    @@global_invoice_number += 1
    "BEE-#{format('%05d', @@global_invoice_number)}"
  end
  # rubocop:enable Style/ClassVars

  def create_billings_for_current_year(localpool)
    contracts_ended_this_year = localpool.contracts.where('end_date BETWEEN ? AND ?', Date.today.at_beginning_of_year, Date.today)
    contracts_ended_this_year.each do |contract|
      logger.debug("Creating billing for contract that ended this year:")
      date_range = Date.today.at_beginning_of_year...contract.end_date
      create_billing(localpool, contract, date_range)
    end
  end
end
