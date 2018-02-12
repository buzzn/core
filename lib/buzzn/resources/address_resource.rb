class AddressResource < Buzzn::Resource::Entity

  model Address

  attributes  :street,
              :city,
              :zip,
              :country

  attributes :updatable, :deletable

end
