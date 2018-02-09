require_relative 'unit'
require 'buzzn/utils/chronos'

class Types::Datasource::Current < Types::Datasource::Unit

  option :value, Types::Strict::Int

  option :register

  def to_json(*)
    # legacy format
    '{"timestamp":' << Buzzn::Utils::Chronos.current_millis.to_s << ',"value":' << value.to_s << ',"resource_id":' << register.id.to_s << ',"mode":"' + register.direction.sub(/put/, '') + '"}'
  end

end
