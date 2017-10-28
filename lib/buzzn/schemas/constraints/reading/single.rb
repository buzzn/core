require_relative '../reading'

Schemas::Constraints::Reading::Single = Buzzn::Schemas.Form do
  required(:raw_value).filled(:float?)
  required(:value).filled(:float?)
  required(:unit).value(included_in?: Reading::Single.units.values)
  required(:reason).value(included_in?: Reading::Single.reasons.values)
  required(:read_by).value(included_in?: Reading::Single.read_by.values)
  required(:quality).value(included_in?: Reading::Single.qualities.values)
  required(:source).value(included_in?: Reading::Single.sources.values)
  required(:status).value(included_in?: Reading::Single.status.values)
  optional(:comment).filled(:str?, max_size?: 256)
  optional(:date).filled(:date?)
end
