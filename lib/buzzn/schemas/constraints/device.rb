require_relative '../constraints'
require './app/models/device.rb'

module Schemas::Constraints

  DeviceCommon = Schemas::Support.Form do
    required(:two_way_meter).value(included_in?: Device.two_way_meters.values)
    required(:two_way_meter_used).value(included_in?: Device.two_way_meter_useds.values)
    required(:primary_energy).value(included_in?: Device.primary_energies.values)
    required(:commissioning).filled(:date?)
    optional(:law).value(included_in?: Device.laws.values)
    optional(:manufacturer).filled(:str?, max_size?: 64)
  end

  Device = Schemas::Support.Form(DeviceCommon) do
    required(:watt_peak).filled(:int?)
    required(:watt_hour_pa).filled(:int?)
  end

end
