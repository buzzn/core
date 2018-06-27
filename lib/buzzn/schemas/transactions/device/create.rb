require_relative '../../constraints/device'
require_relative '../device'

Schemas::Transactions::Device::Create = Schemas::Support.Form(Schemas::Constraints::DeviceCommon) do
  required(:kw_peak).filled(:float?)
  required(:kwh_per_annum).filled(:float?)
end
