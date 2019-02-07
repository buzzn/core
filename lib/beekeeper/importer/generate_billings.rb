#
# Generate closed billings for contracts that have ended and have been billed in beekeeper.
# When we do _our_ billing, we need those so we know which energy consumption is already billed.
#
class Beekeeper::Importer::GenerateBillings

  attr_reader :logger
  attr_reader :operator

  LAST_BEEKEEPER_BILLING_CYCLE_YEAR = 2017

  def initialize(logger, operator)
    @logger = logger
    @logger.section = 'generate-billings'
    @operator = operator
  end

  def run(localpool)
    # First, create the billing cycles with their different ranges (initial, yearly and final).
    # That way the following code can be written (almost) without special cases.
    create_billing_cycles(localpool)
    create_billings_for_current_year(localpool)
  end

  private

  def create_billing_cycles(localpool)
    return [] if localpool.start_date.year == Date.today.year # nothing to do for those
    last_dates = []
    # yearly ranges since then
    (localpool.start_date.year..LAST_BEEKEEPER_BILLING_CYCLE_YEAR).each do |year|
      last_dates << Date.new(year, 12, 31)
    end
    last_dates.map { |last_date| create_billing_cycle(localpool, last_date) }
  end

  def create_billing_cycle(localpool, last_date)
    localpoolr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id)
    name = "#{localpoolr.next_billing_cycle_begin_date} - #{last_date}"
    params = {
      last_date: last_date,
      name: name
    }
    logger.info("Creating billing cycle #{name}")
    Transactions::Admin::BillingCycle::Create.new.(resource: localpoolr,
                                                   params: params)
  end

  def range_spans_one_year?(date_range)
    ((date_range.first.year + 1) == date_range.last.year) &&
      [date_range.first.month, date_range.first.day, date_range.last.month, date_range.last.day].all? { |nr| nr == 1 }
  end

  def create_billings(localpool, billing_cycle)
    billings = []
    localpool.register_metas
      .select{ |ml| ml.register.consumption? }
      .each do |register_meta|
      contracts_to_bill(register_meta, billing_cycle.date_range).each do |contract|
        date_range = billing_date_range(contract, billing_cycle)
        if contract.is_a? Contract::LocalpoolPowerTaker
          billings << create_billing(localpool, contract, date_range, billing_cycle)
        end
      end
    end
    billings.flatten
  end

  def contracts_to_bill(register_meta, date_range)
    #register_meta.contracts_in_date_range(date_range).without_third_party
    # FIXME: create fake billings for third party contracts; right now that's the only way to show them on the the billing cycle page
    register_meta.contracts_in_date_range(date_range)
  end

  def create_billing(localpool, contract, date_range, billing_cycle = nil)
    billingsr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id).contracts.retrieve(contract.id).billings
    params = {
      begin_date: date_range.first,
      last_date:  date_range.last,
    }
    Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                              params: params,
                                              contract: contract,
                                              billing_cycle: billing_cycle)
    logger.debug("Created billing for contract #{contract.id} (#{date_range})")
  end

  def billing_date_range(contract, billing_cycle)
    begin_date = [billing_cycle.date_range.first, contract.begin_date].max
    end_date   = contract.end_date ? [billing_cycle.date_range.last, contract.end_date].min : billing_cycle.date_range.last
    begin_date...end_date
  end

  def item_for_contract(contract, date_range)
    Builders::Billing::ItemBuilder.from_contract(contract, contract.register_meta.register, date_range, contract.tariffs.first)
  end

  def next_invoice_number
    $global_invoice_number ||= Billing.count
    $global_invoice_number += 1
    "BEE-#{format('%05d', $global_invoice_number)}"
  end

  def create_billings_for_current_year(localpool)
    contracts_ended_this_year = localpool.contracts.where('end_date BETWEEN ? AND ?', Date.today.at_beginning_of_year, Date.today)
    contracts_ended_this_year.each do |contract|
      logger.debug('Creating billing for contract that ended this year:')
      date_range = Date.today.at_beginning_of_year...contract.end_date
      create_billing(localpool, contract, date_range)
    end
  end

end
