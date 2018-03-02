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

  def build_bricks(bricks)
    return [] unless bricks
    bricks.collect do |brick|
      { contract_type: brick.contract_type, begin_date: brick.date_range.first.as_json, end_date: brick.date_range.last.as_json, status: brick.status }
    end
  end

end
