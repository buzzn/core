require './app/models/device.rb'
require_relative '../device'
require_relative '../id'

Schemas::Transactions::Device::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:two_way_meter).value(included_in?: Device.two_way_meters.values)
  optional(:two_way_meter_used).value(included_in?: Device.two_way_meter_useds.values)
  optional(:primary_energy).value(included_in?: Device.primary_energies.values)
  optional(:commissioning).filled(:date?)
  optional(:law).value(included_in?: Device.laws.values)
  optional(:manufacturer).filled(:str?, max_size?: 64)
  optional(:kw_peak).filled(:float?)
  optional(:kwh_per_annum).filled(:float?)
  optional(:electricity_supplier).schema(Schemas::Transactions::Id)
end
