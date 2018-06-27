require './app/models/device.rb'
require_relative '../../constraints/device'
require_relative '../device'
require_relative '../id'

Schemas::Transactions::Device::Create = Schemas::Support.Form(Schemas::Constraints::DeviceCommon) do
  required(:kw_peak).filled(:float?)
  required(:kwh_per_annum).filled(:float?)
  optional(:electricity_supplier).schema(Schemas::Transactions::Id)
end
