class ReadingResource < Buzzn::Resource::Base

  model SingleReading

  attributes :id, :type
  attributes :date,
             :raw_value,
             :value,
             :unit,
             :reason,
             :read_by,
             :source,
             :quality,
             :status,
             :comment

  def type; 'reading'; end

  def value
    object.corrected_value.normal.value
  end

  def unit
    object.corrected_value.unit
  end
end
