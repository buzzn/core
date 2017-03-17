class AddressSerializer < ActiveModel::Serializer

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
class GuardedAddressSerializer < AddressSerializer

  attributes :updatable, :deletable

  def initialize(user, *args)
    super(*args)
    @current_user = user
  end

  def updatable
    object.updatable_by?(@current_user)
  end

  def deletable
    object.deletable_by?(@current_user)
  end
end
