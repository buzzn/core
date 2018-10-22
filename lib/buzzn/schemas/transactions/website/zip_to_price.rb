require_relative '../website'
require_relative '../../../types/zip_price'

Schemas::Transactions::Website::ZipToPrice = Schemas::Support.Form do
  required(:type).value(included_in?: Types::MeterTypes.values)
  required(:zip).value(:int?)
  required(:annual_kwh).value(:int?)
end
