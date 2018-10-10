require_relative '../operations'

class Operations::Discovergy

  include Dry::Transaction::Operation
  include Import['services.datasource.discovergy.meters']

  def call(resource:, **)
    meter = resource.object
    if meter.discovergy?
      begin
        connected = meters.connected?(meter)
      rescue Buzzn::DataSourceError
        raise Buzzn::ValidationError.new(datasource: 'discovergy: invalid id')
      end
      unless connected
        raise Buzzn::ValidationError.new(datasource: 'meter must be connected with discovergy')
      end
    end
    true
  end

end
