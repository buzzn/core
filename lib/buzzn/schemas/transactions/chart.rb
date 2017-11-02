require_relative '../transactions'

Schemas::Transactions::Chart = Buzzn::Schemas.Form do
  required(:duration).value(included_in?: ['year', 'month', 'day', 'hour'])
  optional(:timestamp).filled(:time?)
end
