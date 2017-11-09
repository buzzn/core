require_relative '../display'
require_relative '../../schemas/transactions/display/score'

class Transactions::Display::Score < Transactions::Base
  def self.for(group)
    super(Schemas::Transactions::Display::Score, group, :authorize, :scores)
  end

  step :validate, with: :'operations.validation'
  step :authorize
  step :scores

  def authorize(input, group)
    # TODO needs to distinguish between admin and display
    # TODO check privacy settings here
    Right(input)
  end

  def scores(input, group)
    timestamp = input[:timestamp] || Buzzn::Utils::Chronos.now
    if timestamp > Buzzn::Utils::Chronos.now.beginning_of_day
      timestamp = timestamp - 1.day
    end
    result = group.object.scores
               .send("#{input[:interval]}ly")
               .containing(timestamp)
    if mode = input[:mode]
      result = result.send(mode.to_s.pluralize)
    end

    Right(group.all(group.permissions.scores, result, Display::ScoreResource))
  end
end
