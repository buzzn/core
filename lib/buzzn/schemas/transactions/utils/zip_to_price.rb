require_relative '../utils'

Schemas::Transactions::Utils::ZipToPrice = Schemas::Support.Form do
  required(:type).value(included_in?: Buzzn::Types::MeterTypes.values)
  optional(:zip).filled(:int?)
  optional(:annual_kwh).filled(:int?)
end
