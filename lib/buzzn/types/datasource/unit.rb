require_relative '../datasource'

class Types::Datasource::Unit
  extend Dry::Initializer

  Unit = Types::Strict::Symbol.enum(*%i(W Wh))

  option :unit, Unit

end
