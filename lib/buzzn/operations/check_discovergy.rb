require_relative '../operations'

class Operations::CheckDiscovergy

  include Dry::Transaction::Operation
  include Import['services.datasource.discovergy.meters']

  def call(resource)
    meter = resource.object
    if meter.discovergy? && !meters.connected?(meter)
      Failure("meter #{meter} is not connected with discovergy")
    else
      Success(resource)
    end
  end

end
