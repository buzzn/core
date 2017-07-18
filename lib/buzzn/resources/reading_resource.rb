class ReadingResource < Buzzn::Resource::Base

  model Reading

  attributes :id, :type
  attributes :energy_milliwatt_hour,
             :power_milliwatt,
             :timestamp,
             :reason,
             :source,
             :quality,
             :meter_serialnumber

  def type; 'reading'; end

  # use nice id format
  def id
    object.id.to_s
  end

end
