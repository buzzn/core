class AddressResource < Buzzn::EntityResource

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

# TODO get rid of the need of having a Serializer class
class AddressSerializer < AddressResource
  def self.new(*args)
    super
  end
end

