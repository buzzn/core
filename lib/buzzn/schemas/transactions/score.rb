require_relative '../transactions'

Schemas::Transactions::Score = Buzzn::Schemas.Form do
  required(:interval).value(included_in?: ['year', 'month', 'day'])
  required(:timestamp).filled(:time?)
  optional(:mode).value(included_in?: ['sufficiency', 'closeness', 'autarchy', 'fitting'])
end
