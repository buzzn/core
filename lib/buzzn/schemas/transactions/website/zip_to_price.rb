require_relative '../website'
require_relative '../../../types/zip_price'

Schemas::Transactions::Website::ZipToPrice = Schemas::Support.Form do
  required(:type).value(included_in?: Types::MeterTypes.values)
  optional(:zip).filled(:int?)
  optional(:annual_kwh).filled(:int?)
end
