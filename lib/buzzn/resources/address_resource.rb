class AddressResource < Buzzn::Resource::Entity

  model Address

  attributes  :street,
              :city,
              :state,
              :zip,
              :country

  attributes :updatable, :deletable
end

