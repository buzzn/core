class ReadingResource < JSONAPI::Resource
  attributes  :energy_milliwatt_hour,
              :power_milliwatt,
              :timestamp,
              :register_id,
              :reason,
              :source,
              :quality
end
