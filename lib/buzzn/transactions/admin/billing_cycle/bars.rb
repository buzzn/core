require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::Bars < Transactions::Base

  def self.for(billing_cycle)
    new.with_step_args(
      authorize: [billing_cycle, *billing_cycle.permissions.retrieve]
    )
  end

  step :authorize, with: :'operations.authorization.generic'
  step :bars, with: :'operations.bars'
  step :result_builder

  def result_builder(data)
    result = {
      array: data.collect do |item|
        build_bars_location(item[:market_location], item[:bars])
      end
    }
    Right(result)
  end

  private

  def build_bars_location(market_location, bars)
    { id: market_location.id, type: 'market_location', name: market_location.name, bars: { array: build_bars(bars) } }
  end

  BAR_FIELDS = %i(billing_id contract_type begin_date end_date status consumed_energy_kwh price_cents)

  def build_bars(bars)
    return [] unless bars
    bars.collect { |bar| bar_as_json(bar, BAR_FIELDS) }
  end

  def bar_as_json(bar, fields)
    returned_hash = fields.each.with_object({}) { |field, hash| hash[field.to_s] = bar.send(field) }
    returned_hash.merge(errors(bar)).as_json
  end

  def errors(bar)
    bar.invariant.errors.empty? ? {} : { errors: bar.invariant.errors(full: true) }
  end

end
