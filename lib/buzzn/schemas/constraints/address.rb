require_relative '../constraints'

Schemas::Constraints::Address = Buzzn::Schemas.Form do
  required(:street).filled(:str?,  max_size?: 64)
  required(:zip).filled(:str?, max_size?: 16)
  required(:city).filled(:str?, max_size?: 64)
  required(:country).value(included_in?: Address.countries.values)
  optional(:addition).filled(:str?, max_size?: 64)
  optional(:state).value(included_in?: Address.states.values)
end
