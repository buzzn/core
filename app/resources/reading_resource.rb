class ReadingSerializer < ActiveModel::Serializer

  attributes  :energy_milliwatt_hour,
              :power_milliwatt,
              :timestamp,
              :register_id,
              :reason,
              :source,
              :quality
end
