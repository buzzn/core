require_relative '../datasource'

class Types::Datasource::Unit
  extend Dry::Initializer

  Unit = Types::Strict::Symbol.enum(*%i(W Wh))

  option :unit, Unit

  def to_json(*)
    # TODO: '{"unit":"' << unit.to_s << '"'
  end
end
