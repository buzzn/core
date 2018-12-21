require_relative '../website'
require_relative '../../../types/zip_price'

Schemas::Transactions::Website::ZipToPrice = Schemas::Support.Form do
  required(:type).value(included_in?: Types::MeterTypes.values)
  required(:zip).value(:str?, max_size?: 5)
  required(:annual_kwh).value(:int?)
end
