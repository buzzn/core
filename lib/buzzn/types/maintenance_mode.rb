require_relative '../types'

class Types::MaintenanceMode < Dry::Struct

  Modes = Types::Coercible::String.enum('on', 'off')

  attribute :maintenance_mode, Modes

end
