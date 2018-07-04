module Admin
  class DeviceResource < Buzzn::Resource::Entity

    model Device

    attributes :two_way_meter,
               :two_way_meter_used,
               :primary_energy,
               :commissioning,
               :kw_peak,
               :kwh_per_annum,
               :law,
               :manufacturer,
               :updatable, :deletable

    has_one :electricity_supplier

    def kw_peak
      watt_peak / 1000.0
    end

    def kwh_per_annum
      watt_hour_pa / 1000.0
    end

  end
end
