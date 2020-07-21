require_relative 'unit'

class Types::Datasource::Bubble

  extend Dry::Initializer

  option :value, Types::Strict::Integer

  option :register

  def to_json(*)
    as_json.to_json
  end

  def as_json(*)
    # privacy: only supply names of consumption_common and production*
    {
      id: register.id,
      label: register.meta.label,
      value: value
    }.tap do |h|
      if h[:label].to_s == 'consumption_common' ||
         h[:label].to_s.start_with?('production')
        h[:name] = register.meta.name
      end
    end
  end

end
