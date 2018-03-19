require_relative '../builders/billing/item_builder'

class Services::UnbilledBillingItemsFactory

  def call(group:, date_range:)
    group.market_locations.consumption.map do |market_location|
      billing_items_for_market_location(market_location, date_range)
    end
  end

  private

  def billing_items_for_market_location(market_location, date_range)
    unbilled_date_range = unbilled_date_range(market_location, date_range)
    build_unbilled_items(market_location, unbilled_date_range)
  end

  def build_unbilled_items(market_location, date_range)
    return [] if date_range_zero?(date_range)
    # We don't handle register and tariff changes in the first billing story.
    # So we can keep it simple -- each contract will result in one item.
    market_location.contracts_in_date_range(date_range).map { |contract| build_item(contract, date_range) }
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
