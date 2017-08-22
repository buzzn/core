class ReadingResource < Buzzn::Resource::Entity

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

  attributes :updatable, :deletable

  def type; 'reading'; end

  def value
    object.corrected_value.value
  end

end
