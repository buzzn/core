class MeterSerializer < ActiveModel::Serializer
  attributes  :id,
              :manufacturer_name,
              :manufacturer_product_name,
              :manufacturer_product_serialnumber,
              :smart,
              :online

end
