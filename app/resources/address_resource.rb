class AddressResource < ApplicationResource

  attributes  :address,
              :street_name,
              :street_number,
              :city,
              :state,
              :zip,
              :country,
              :longitude,
              :latitude,
              :addition,
              :time_zone

end
