require './app/models/device.rb'
require_relative '../device'
require_relative '../id'

Schemas::Transactions::Device::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:primary_energy).value(included_in?: Device.primary_energies.values)
  optional(:commissioning).filled(:date?)
  optional(:law).value(included_in?: Device.laws.values)
  optional(:manufacturer).filled(:str?, max_size?: 64)
  optional(:model).filled(:str?, max_size?: 64)
  optional(:name).filled(:str?, max_size?: 64)
  optional(:kw_peak).filled(:float?)
  optional(:kwh_per_annum).filled(:float?)
end
