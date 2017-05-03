class PriceResource < Buzzn::EntityResource

  model Price

  attributes  :name,
              :begin_date,
              :energyprice_cents_per_kilowatt_hour,
              :baseprice_cents_per_month

  attributes :updatable, :deletable
end