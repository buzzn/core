require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::Bars < Transactions::Base

  def self.for(billing_cycle)
    new.with_step_args(
      authorize: [billing_cycle, *billing_cycle.permissions.retrieve],
      load_billings: [billing_cycle]
    )
  end

  step :authorize, with: :'operations.authorization.generic'
  step :load_billings
  step :result_builder

  def result_builder(data)
    result = {
      array: data.collect do |market_location, billings|
        build_bars_location(market_location, billings)
      end
    }
    Right(result)
  end

  private

  def load_billings(_inputs, billing_cycle)
    billings = billing_cycle.billings.includes(contract: :market_location)
    grouped = billings.group_by { |billing| billing.contract.market_location }
    Right(grouped)
  end

  def build_bars_location(market_location, billings)
    { id: market_location.id, type: 'market_location', name: market_location.name, bars: { array: build_bars(billings) } }
  end

  FIELDS = %i(billing_id contract_type begin_date end_date status consumed_energy_kwh price_cents)

  def build_bars(billings = [])
    billings.collect { |billing| bar_as_json(billing, FIELDS) }
  end

  def bar_as_json(bar, fields)
    returned_hash = fields.each.with_object({}) { |field, hash| hash[field.to_s] = bar.send(field) }
    returned_hash.merge(errors(bar)).as_json
  end

  def errors(bar)
    bar.invariant.errors.empty? ? {} : { errors: bar.invariant.errors(full: true) }
  end

end
