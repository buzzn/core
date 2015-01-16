class MeteringPointSerializer < ActiveModel::Serializer
  attributes  :id,
              :uid,
              :address_addition

  has_one :meter
end
