require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::Bars < Transactions::Base

  def self.for(billing_cycle)
    new.with_step_args(
      authorize: [billing_cycle, *billing_cycle.permissions.retrieve]
    )
  end

  step :authorize, with: :'operations.authorization.generic'
  step :items, with: :'operations.items'
  step :result_builder

  def result_builder(data)
    result = {
      array: data.collect do |item|
        build_items_location(item[:market_location], item[:items])
      end
    }
    Right(result)
  end

  private

  def build_items_location(market_location, items)
    { id: market_location.id, type: 'market_location', name: market_location.name, items: { array: build_items(items) } }
  end

  BRICK_FIELDS = %i(contract_type begin_date end_date status consumed_energy_kwh price_cents)

  def build_items(items)
    return [] unless items
    items.collect { |item| item_as_json(item, BRICK_FIELDS) }
  end

  def item_as_json(item, fields)
    returned_hash = fields.each.with_object({}) { |field, hash| hash[field.to_s] = item.send(field) }
    returned_hash.merge(errors(item)).as_json
  end

  def errors(item)
    item.invariant.errors.empty? ? {} : { errors: item.invariant.errors(full: true) }
  end

end
