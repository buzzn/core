class AddressResource < Buzzn::Resource::Entity

  model Address

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
  
  attributes :updatable, :deletable
end

