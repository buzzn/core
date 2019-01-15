require './app/models/reading/single.rb'
require_relative '../reading'

Schemas::Constraints::Reading::Single = Schemas::Support.Form do
  required(:raw_value).filled(:bigint?)
  required(:value).filled(:bigint?)
  required(:unit).value(included_in?: Reading::Single.units.values)
  required(:reason).value(included_in?: Reading::Single.reasons.values)
  required(:read_by).value(included_in?: Reading::Single.read_by.values)
  required(:quality).value(included_in?: Reading::Single.qualities.values)
  required(:source).value(included_in?: Reading::Single.sources.values)
  required(:status).value(included_in?: Reading::Single.status.values)
  required(:date).filled(:date?)
  optional(:comment).maybe(:str?, max_size?: 256)
end
