require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::Bricks < Transactions::Base

  def self.for(billing_cycle)
    new.with_step_args(
      authorize: [billing_cycle, *billing_cycle.permissions.retrieve]
    )
  end

  step :authorize, with: :'operations.authorization.generic'
  step :bricks, with: :'operations.bricks'
  step :result_builder

  def result_builder(data)
    result = {
      array: data.collect do |item|
        build_bricks_location(item[:market_location], item[:bricks])
      end
    }
    Right(result)
  end

  private

  def build_bricks_location(market_location, bricks)
    { id: market_location.id, type: 'market_location', name: market_location.name, bricks: { array: build_bricks(bricks) } }
  end

  BRICK_FIELDS = %i(contract_type begin_date end_date status consumed_energy_kwh energy_price_cents base_price_cents)
  def build_bricks(bricks)
    return [] unless bricks
    bricks.collect do |brick|
      BRICK_FIELDS.each.with_object({}) { |field, hash| hash[field] = brick.send(field).as_json }
    end
  end

end
