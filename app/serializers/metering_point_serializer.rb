class MeteringPointSerializer < ActiveModel::Serializer
  attributes  :id,
              :uid,
              :name

  has_one :meter
end
