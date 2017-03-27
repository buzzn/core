class MinimalDeviceResource < Buzzn::EntityResource

  model Device

  attributes  :name,
              :manufacturer_name,
              :manufacturer_product_name,
              :manufacturer_product_serialnumber,
              :mode,
              :law,
              :category,
              :shop_link,
              :primary_energy,
              :watt_peak,
              :watt_hour_pa,
              :commissioning,
              :mobile,
              :readable

  attributes :updatable, :deletable

end

# we do not want all infos in collections
class DeviceResource < MinimalDeviceResource

  attributes :big_tumb

  def big_tumb
    object.image.big_tumb.url
  end

end

# TODO get rid of the need of having a Serializer class
class DeviceSerializer < MinimalDeviceResource
  def self.new(*args)
    super
  end
end
