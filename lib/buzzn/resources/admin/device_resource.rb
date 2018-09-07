module Admin
  class DeviceResource < Buzzn::Resource::Entity

    model Device

    attributes :primary_energy,
               :commissioning,
               :kw_peak,
               :kwh_per_annum,
               :law,
               :manufacturer,
               :name,
               :model,
               :updatable, :deletable

    def kw_peak
      watt_peak / 1000.0
    end

    def kwh_per_annum
      watt_hour_pa / 1000.0
    end

  end
end
