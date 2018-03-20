require_relative '../builders/billing/item_builder'

#
# Returns all unbilled billing items for a list of market locations and a date range.
# The unbilled billing items are unsaved, so that they can be used for display only or persistance within
# a Billing and maybe BillingCycle.
#
class Services::UnbilledBillingItemsFactory

  # Returns this structure:
  # [
  #   {
  #    market_location: <MaLo id:5>
  #    contracts: [
  #      {
  #        contract: <Contract id:5>
  #        billing_items: [
  #          <BillingItem (not persisted)>
  #        ]
  #      }
  #    ]
  #
  #   }
  # ]
  def call(market_locations:, date_range:)
    market_locations.each.with_object([]) do |market_location, array|
      array << {
        market_location: market_location,
        contracts: contracts_with_items(market_location, date_range)
      }
    end
  end

  private

  def contracts_with_items(market_location, date_range)
    contracts, unbilled_date_range = unbilled_contracts(market_location, date_range)
    contracts.map.with_object([]) do |contract, array|
      array << {
        contract: contract,
        # We don't handle register and tariff changes yet, so we always return an array with one item, rather than 2+
        # later (register and tariff changes will cause new items).
        items: [build_item(contract, unbilled_date_range)]
      }
    end
  end

  def unbilled_contracts(market_location, date_range)
    return [] if date_range_zero?(date_range)
    unbilled_date_range = unbilled_date_range(market_location, date_range)
    contracts = market_location.contracts_in_date_range(unbilled_date_range)
    [contracts, unbilled_date_range]
  end

  def build_item(contract, date_range)
    Builders::Billing::ItemBuilder.from_contract(contract, date_range)
  end

  # Ruby can't calculate the length (in days) of a range object when the range is defined with dates -- it always returns nil.
  # TODO: use exclude_end? to prevent one-off errors
  def date_range_zero?(date_range)
    date_range.last == date_range.first
  end

  def unbilled_date_range(market_location, date_range)
    last_billing = last_billing_for(market_location, date_range)
    last_billing ? last_billing.end_date...date_range.last : date_range
  end

  def last_billing_for(market_location, date_range)
    market_location.billings_in_date_range(date_range).order(:end_date).last
  end

end
