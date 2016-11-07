class MeterResource < ApplicationResource

  attributes  :manufacturer_name,
              :manufacturer_product_name,
              :manufacturer_product_serialnumber,
              :smart,
              :online

  has_many :registers

end
