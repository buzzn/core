class DeviceResource < JSONAPI::Resource

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
    @model.image.big_tumb.url
  end

end
