require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_reading_schema) do
    optional(:date).filled(:date?)
    required(:raw_value).filled(:float?)
    required(:value).filled(:float?)
    required(:unit).value(included_in?: SingleReading::UNITS)
    required(:reason).value(included_in?: SingleReading::REASONS)
    required(:read_by).value(included_in?: SingleReading::READ_BY_VALUES)
    required(:quality).value(included_in?: SingleReading::QUALITIES)
    required(:source).value(included_in?: SingleReading::SOURCES)
    required(:status).value(included_in?: SingleReading::STATUS)
    optional(:comment).filled(:str?, max_size?: 256)
  end

  t.define(:create_reading) do
    validate :create_reading_schema
    step :resource, with: :nested_resource
  end
end
