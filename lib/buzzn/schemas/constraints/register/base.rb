require_relative 'common'

Schemas::Constraints::Register::Base = Buzzn::Schemas.Form(Schemas::Constraints::Register::Common) do
  required(:name).filled(:str?, max_size?: 64)
  required(:direction).value(included_in?: Register::Base.directions.values)
  required(:obis).filled(:str?, max_size?: 16)
  required(:share_with_group).filled(:bool?)
  optional(:share_publicly).filled(:bool?)
  optional(:low_load_ability).filled(:bool?)
end
