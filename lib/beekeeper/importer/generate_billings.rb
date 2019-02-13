# coding: utf-8
#
# Generate closed billings for contracts that have ended and have been billed in beekeeper.
# When we do _our_ billing, we need those so we know which energy consumption is already billed.
#
class Beekeeper::Importer::GenerateBillings

  attr_reader :logger
  attr_reader :operator

  LAST_BEEKEEPER_BILLING_CYCLE_YEAR = 2018

  def initialize(logger, operator)
    @logger = logger
    @logger.section = 'generate-billings-and-cycles'
    @operator = operator
  end

  def run(localpool, record)
    # First, create the billing cycles with their different ranges (initial, yearly and final).
    # That way the following code can be written (almost) without special cases.
    create_billing_cycles(localpool, record)
    #create_billings_for_current_year(localpool)
  end

  private

  def create_billing_cycles(localpool, record)
    return [] if localpool.start_date.year == Date.today.year # nothing to do for those
    last_dates = []
    accounting_service = Import.global('services.accounting')
    # yearly ranges since then
    (localpool.start_date.year..LAST_BEEKEEPER_BILLING_CYCLE_YEAR).each do |year|
      last_dates << Date.new(year, 12, 31)
    end
    last_dates.map do |last_date|
      begin
        create_gap_contracts(localpool, last_date)
        billing_cycle = create_billing_cycle(localpool, last_date)
        set_billing_cycle_to_calculated(localpool, billing_cycle)
        if last_date.year != 2018
          set_billing_cycle_to_closed(localpool, billing_cycle)
        end
        book_paid_payments(localpool, record, last_date.year)

        if last_date.year == 2017
          # reset balances for the localpool
          localpool.contracts.each do |contract|
            balance = accounting_service.balance(contract)
            unless balance.zero?
              accounting_service.book(operator, contract, -1*balance, comment: 'Ausgleich Import 2019')
            end
          end
        end
        billing_cycle
      rescue ArgumentError
        break
      end
    end
  end

  def book_paid_payments(localpool, record, year)
    accounting_service = Import.global('services.accounting')
    localpool.contracts.each do |contract|
      record_contract = record.select {|x| x[:contract_number] == contract.contract_number && x[:contract_number_addition] == contract.contract_number_addition}.first
      next unless record_contract
      paid = record_contract[:paid_payments].select {|x| x[:year] == year}&.first&.[](:paid)
      if paid
        accounting_service.book(operator, contract, paid*10*100, comment: "Bezahlte Abschläge #{year}")
      elsif year == 2018
        logger.warn('No payment for 2018', extra_data: { contract: contract.attributes } )
      end
    end
  end

  def create_gap_contracts(localpool, last_date)
    localpoolr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id)
    gap_contractsr= localpoolr.localpool_gap_contracts
    request = {
      begin_date: localpoolr.next_billing_cycle_begin_date,
      last_date: last_date,
    }
    logger.info("Creating gap contracts #{localpool.name} #{request}")
    Transactions::Admin::Contract::Localpool::CreateGapContracts.new.(resource: gap_contractsr, params: request, localpool: localpoolr)
  rescue Buzzn::ValidationError => e
    logger.error("Buzzn::ValidationError for gap contract", extra_data: e.errors)
    raise ArgumentError
  end

  def create_billing_cycle(localpool, last_date)
    localpoolr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id)
    localpoolr.object.reload
    name = "#{localpoolr.next_billing_cycle_begin_date} - #{last_date}"
    params = {
      last_date: last_date,
      name: name
    }
    logger.info("Creating billing cycle #{name}")
    result = Transactions::Admin::BillingCycle::Create.new.(resource: localpoolr, params: params)
    result.value!.object
  rescue Buzzn::ValidationError => e
    if e.errors["create_billings"]
      e.errors["create_billings"] = e.errors["create_billings"].map do |err|
        err.map do |k,v|
          if k == :contract_id
            contract = Contract::Base.find(v)
            { :contract => contract.attributes.merge(register_meta: contract.register_meta.attributes.merge(meters: contract.register_meta.registers.map { |x| x.meter.attributes })) }
          else
            { k => v }
          end
        end
      end
    end
    logger.error("Buzzn::ValidationError for billing_cycle #{name}", extra_data: e.errors)
    raise ArgumentError
  end

  def set_billing_cycle_to_calculated(localpool, billing_cycle)
    localpoolr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id)
    billing_cycler = localpoolr.billing_cycles.retrieve(billing_cycle.id)
    billing_cycler.object.billings.each do |billing|
      billing.reload
      billingr = billing_cycler.billings.retrieve(billing.id)
      billingr.object.reload
      begin
        Transactions::Admin::Billing::Update.new.(resource: billingr, params: {status: 'calculated', updated_at: billingr.object.updated_at.to_json})
      rescue Buzzn::ValidationError => e
        blogger = if billing_cycle.end_date == Date.new(2019, 1, 1)
                    logger.warn
                  else
                    logger.error
                  end
        blogger.("Buzzn::ValidationError for billing update #{billing.status} -> calculated", extra_data: {errors: e.errors,
                                                                                                           contract: billing.contract.attributes,
                                                                                                           register_meta: billing.contract.register_meta.attributes.merge(meters: billing.contract.register_meta.registers.map { |x| x.meter.attributes }),
                                                                                                           billing: billing.attributes.merge(items: billing.items.map{ |x| x.attributes })
                                                                                                          })
      rescue Buzzn::StaleEntity => e
        byebug.byebug
      end
    end
  end

  def set_billing_cycle_to_closed(localpool, billing_cycle)
    localpoolr = Admin::LocalpoolResource.all(operator).retrieve(localpool.id)
    billing_cycler = localpoolr.billing_cycles.retrieve(billing_cycle.id)
    billing_cycler.object.billings.each do |billing|
      billing.reload
      billingr = billing_cycler.billings.retrieve(billing.id)
      billingr.object.reload
      begin
        Transactions::Admin::Billing::Update.new.(resource: billingr, params: {status: 'closed', updated_at: billingr.object.updated_at.to_json})
      rescue Buzzn::ValidationError => e
        blogger = if billing_cycle.end_date == Date.new(2019, 1, 1)
                    logger.warn
                  else
                    logger.error
                  end
        blogger.("Buzzn::ValidationError for billing update #{billing.status} -> closed", extra_data: {errors: e.errors,
                                                                                                       contract: billing.contract.attributes,
                                                                                                       register_meta: billing.contract.register_meta.attributes.merge(meters: billing.contract.register_meta.registers.map { |x| x.meter.attributes }),
                                                                                                       billing: billing.attributes.merge(items: billing.items.map{ |x| x.attributes })
                                                                                                      })
      rescue Buzzn::StaleEntity => e
        byebug.byebug
      end
    end
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
  rescue Buzzn::ValidationError => e
    logger.error("Buzzn::ValidationError for billing of contract #{contract.id} in date range #{date_range}", extra_data: e.errors)
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
