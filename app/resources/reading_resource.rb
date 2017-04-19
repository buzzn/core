class ReadingResource < Buzzn::EntityResource

  model Reading

  attributes  :energy_milliwatt_hour,
              :power_milliwatt,
              :timestamp,
              :reason,
              :source,
              :quality,
              :meter_serialnumber
end

class ReadingCollectionResource < ReadingResource
end

class ReadingSingleResource < ReadingResource
end
