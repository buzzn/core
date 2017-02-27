class ReadingResource < Buzzn::EntityResource

  model Reading

  attributes  :energy_milliwatt_hour,
              :power_milliwatt,
              :timestamp,
              :reason,
              :source,
              :quality,
              :meter_serialnumber

  # use nice id format
  def id
    object.id.to_s
  end
end
