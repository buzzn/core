require_relative '../billing_cycle'

#
# Returns a hash of (consumption) market locations with the billings for each:
# {
#   array: [
#     {
#       id: 42,
#       type: 'market_location',
#       name: 'Market location name',
#       bars: {
#         array: [
#           { price_cents: ..., billing_id: ... }
#         ]
#       }
#     }
#   ]
# }
#
class Transactions::Admin::BillingCycle::ReadBillings < Transactions::Base

  def self.for(billing_cycle)
    new.with_step_args(
      authorize: [billing_cycle, *billing_cycle.permissions.retrieve]
    )
  end

  step :authorize, with: :'operations.authorization.generic'
  step :find_relevant_market_locations
  step :build_result

  def find_relevant_market_locations(billing_cycle)
    market_locations = billing_cycle.object.localpool.market_locations.order(:name).to_a.select(&:consumption?)
    Success(market_locations: market_locations, billing_cycle: billing_cycle)
  end

  def build_result(input)
    all_billings = input[:billing_cycle].object.billings.includes(:items, :contract).to_a
    result_array = input[:market_locations].map do |market_location|
      billings = all_billings.select { |billing| billing.contract.market_location == market_location }
      build_market_location_row(market_location, billings)
    end
    Success(array: result_array)
  end

  private

  def build_market_location_row(market_location, billings)
    {
      id:   market_location.id,
      type: 'market_location',
      name: market_location.name,
      bars: { array: billings_as_json(billings) }
    }
  end

  def billings_as_json(billings)
    return [] unless billings
    billings.sort_by(&:begin_date).collect { |billing| billing_as_json(billing) }
  end

  FIELDS = %i(billing_id contract_type begin_date end_date status consumed_energy_kwh price_cents)

  def billing_as_json(billing)
    returned_hash = FIELDS.each.with_object({}) do |field, hash|
      # HACK: we can always use the first item here since there's always only one right now.
      hash[field.to_s] = billing.items.first.send(field)
    end
    returned_hash.merge(errors(billing)).as_json
  end

  def errors(billing)
    # HACK: we can always use the first item here since there's always only one right now.
    # Later on, we'll have to move this validation and information to the billing (just sum up the items there correctly).
    item = billing.items.first
    item.invariant.errors.empty? ? {} : { errors: item.invariant.errors(full: true) }
  end
end
