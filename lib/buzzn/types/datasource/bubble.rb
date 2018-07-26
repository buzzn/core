require_relative 'unit'

class Types::Datasource::Bubble

  extend Dry::Initializer

  option :value, Types::Strict::Int

  option :register

  def to_json(*)
    as_json.to_json
  end

  def as_json(*)
    { id: register.id, label: register.meta.label, name: register.name, value: value }
  end

end
