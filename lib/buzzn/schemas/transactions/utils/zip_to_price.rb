require_relative '../utils'
require_relative '../../../types/zip_price'

Schemas::Transactions::Utils::ZipToPrice = Schemas::Support.Form do
  required(:type).value(included_in?: Types::MeterTypes.values)
  optional(:zip).filled(:int?)
  optional(:annual_kwh).filled(:int?)
end
