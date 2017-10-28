require_relative '../utils'

Schemas::Transactions::Utils::ZipToPrice = Buzzn::Schemas.Form do
  required(:type).value(included_in?: Buzzn::Types::MeterTypes.values)
  optional(:zip).filled(:int?)
  optional(:annual_kwh).filled(:int?)
end
