class DeviceSerializer < ApplicationSerializer

  attributes  :id,
              :name,
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

              :big_tumb,
              :updateable, :deletable

end
