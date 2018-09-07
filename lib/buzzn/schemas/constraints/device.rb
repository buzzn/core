require_relative '../constraints'
require './app/models/device.rb'

module Schemas::Constraints

  DeviceCommon = Schemas::Support.Form do
    required(:primary_energy).value(included_in?: Device.primary_energies.values)
    required(:commissioning).filled(:date?)
    optional(:law).value(included_in?: Device.laws.values)
    optional(:manufacturer).filled(:str?, max_size?: 64)
    optional(:model).filled(:str?, max_size?: 64)
    optional(:name).filled(:str?, max_size?: 64)
  end

  Device = Schemas::Support.Form(DeviceCommon) do
    required(:watt_peak).filled(:int?)
    required(:watt_hour_pa).filled(:int?)
  end

end
