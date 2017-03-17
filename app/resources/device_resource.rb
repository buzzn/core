class DeviceSerializer < ActiveModel::Serializer

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
              :readable,
              :big_tumb

  def big_tumb
    object.image.big_tumb.url
  end

end
class GuardedDeviceSerializer < DeviceSerializer

  attributes :updatable, :deletable

  def initialize(user, *args)
    super(*args)
    @current_user = user
  end

  def updatable
    object.updatable_by?(@current_user)
  end

  def deletable
    object.deletable_by?(@current_user)
  end
end
