require_relative 'common'

Schemas::Constraints::Register::Base = Schemas::Support.Form(Schemas::Constraints::Register::Common) do
  required(:label).value(included_in?: Register::Base.labels.values)
  required(:direction).value(included_in?: Register::Base.directions.values)
  required(:share_with_group).filled(:bool?)
  optional(:share_publicly).filled(:bool?)
end
