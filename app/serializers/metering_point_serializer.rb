class MeteringPointSerializer < ActiveModel::Serializer
  attributes  :id,
              :uid,
              :name,
              :mode,
              :device_ids,
              :meter_id

end
